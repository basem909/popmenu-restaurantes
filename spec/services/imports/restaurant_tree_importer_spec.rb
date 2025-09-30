# frozen_string_literal: true
require "rails_helper"

RSpec.describe Imports::RestaurantTreeImporter, type: :service do
  # Helper: run the importer against a Ruby hash payload
  def run_import!(payload_hash)
    json = JSON.generate(payload_hash)
    described_class.new(json).call
  end

  # Small matcher helper for clarity
  def not_change(model, method)
    change(model, method).by(0)
  end

  # DB default helper for price
  def db_price_default
    MenuItem.columns_hash["price"].default
  end

  # Canonical sample from the prompt (supports both "menu_items" and "dishes")
  let(:payload) do
    {
      "restaurants" => [
        {
          "name" => "Poppo's Cafe",
          "menus" => [
            {
              "name" => "lunch",
              "menu_items" => [
                { "name" => "Burger",      "price" => 9.00 },
                { "name" => "Small Salad", "price" => 5.00 }
              ]
            },
            {
              "name" => "dinner",
              "menu_items" => [
                { "name" => "Burger",      "price" => 15.00 },
                { "name" => "Large Salad", "price" => 8.00  }
              ]
            }
          ]
        },
        {
          "name" => "Casa del Poppo",
          "menus" => [
            {
              "name" => "lunch",
              "dishes" => [
                { "name" => "Chicken Wings", "price" => 9.00 },
                { "name" => "Burger",        "price" => 9.00 },
                { "name" => "Chicken Wings", "price" => 9.00 } # duplicate in same menu
              ]
            },
            {
              "name" => "dinner",
              "dishes" => [
                { "name" => "Mega \"Burger\"",       "price" => 22.00 },
                { "name" => "Lobster Mac & Cheese", "price" => 31.00 }
              ]
            }
          ]
        }
      ]
    }
  end

  describe "#call" do
    it "creates restaurants, menus, items, and per-menu priced links; aggregates counts; no errors" do
      result = nil

      expect {
        result = run_import!(payload)
      }.to change(Restaurant, :count).by(2)        # Poppo's Cafe, Casa del Poppo
       .and change(Menu,       :count).by(4)        # lunch/dinner x 2
       .and change(MenuItem,   :count).by(7)        # unique items across both restaurants
       .and change(MenuItemization, :count).by(8)   # 4 + 4 links

      expect(result).to be_present
      expect(result.errors).to be_empty

      # First run → all created except the second "Burger" in Poppo's (found)
      expect(result.restaurants_created).to eq(2)
      expect(result.menus_created).to       eq(4)
      expect(result.items_created).to       eq(7)
      expect(result.links_created).to       eq(8)

      expect(result.restaurants_found).to   eq(0)
      expect(result.menus_found).to         eq(0)
      expect(result.items_found).to         eq(1)   # second "Burger" in same restaurant
      expect(result.links_updated).to       eq(0)
      expect(result.links_unchanged).to     eq(0)

      # Verify per-menu pricing in Poppo's Cafe: Burger is 9 on lunch, 15 on dinner
      cafe   = Restaurant.find_by!(name: "Poppo's Cafe")
      lunch  = cafe.menus.find_by!(name: "lunch")
      dinner = cafe.menus.find_by!(name: "dinner")
      burger = cafe.menu_items.find_by!(name: "Burger")

      lunch_link  = MenuItemization.find_by!(menu: lunch,  menu_item: burger)
      dinner_link = MenuItemization.find_by!(menu: dinner, menu_item: burger)

      expect(lunch_link.price_on_menu).to    eq(9.00)
      expect(lunch_link.currency_on_menu).to eq("USD")
      expect(dinner_link.price_on_menu).to    eq(15.00)
      expect(dinner_link.currency_on_menu).to eq("USD")

      # Dedup within a menu ("Chicken Wings" repeated once)
      casa  = Restaurant.find_by!(name: "Casa del Poppo")
      c_lun = casa.menus.find_by!(name: "lunch")
      wings = casa.menu_items.find_by!(name: "Chicken Wings")
      expect(MenuItemization.where(menu: c_lun, menu_item: wings).count).to eq(1)

      # Special chars preserved
      expect(casa.menu_items.find_by!(name: 'Mega "Burger"')).to be_present
    end

    it "is idempotent on a second run (no additional records; reports found/unchanged)" do
      run_import!(payload)

      expect {
        run_import!(payload)
      }.to not_change(Restaurant, :count)
       .and not_change(Menu,       :count)
       .and not_change(MenuItem,   :count)
       .and not_change(MenuItemization, :count)
    end

    it "returns errors and skips invalid records (blank names)" do
      bad = {
        "restaurants" => [
          { "name" => "", "menus" => [] },                        # invalid restaurant
          { "name" => "OK", "menus" => [ { "name" => "" } ] }     # invalid menu
        ]
      }

      result = run_import!(bad)

      expect(result.errors).to be_present
      # Ensure invalid entities were NOT created
      expect(Restaurant.where(name: "").exists?).to be(false)
      expect(Menu.where(name: "").exists?).to be(false)
    end

    it "finds existing restaurant/menu/item by name (case-insensitive) and links with per-menu price" do
      # Precreate with different case
      existing_restaurant = create(:restaurant, name: "poppo's cafe")
      existing_menu       = create(:menu, restaurant: existing_restaurant, name: "LUNCH")

      sub_payload = {
        "restaurants" => [
          {
            "name" => "Poppo's Cafe",
            "menus" => [
              { "name" => "lunch", "menu_items" => [ { "name" => "Burger", "price" => 10.0 } ] }
            ]
          }
        ]
      }

      result = run_import!(sub_payload)

      expect(result.restaurants_found).to be >= 1
      expect(result.menus_found).to       be >= 1

      burger = existing_restaurant.menu_items.find_by!(name: "Burger")
      link   = MenuItemization.find_by!(menu: existing_menu, menu_item: burger)
      expect(link.price_on_menu).to    eq(10.0)
      expect(link.currency_on_menu).to eq("USD")
    end

    it "accepts string prices, trimming/parsable into floats on the link" do
      data = {
        "restaurants" => [
          {
            "name" => "String Price Place",
            "menus" => [
              { "name" => "lunch", "menu_items" => [ { "name" => "Tea", "price" => "  2.50  " } ] }
            ]
          }
        ]
      }

      run_import!(data)

      r   = Restaurant.find_by!(name: "String Price Place")
      m   = r.menus.find_by!(name: "lunch")
      tea = r.menu_items.find_by!(name: "Tea")
      link = MenuItemization.find_by!(menu: m, menu_item: tea)

      expect(link.price_on_menu).to    eq(2.50)
      expect(link.currency_on_menu).to eq("USD")
    end

    it "creates an item; link saved with nil pricing when payload omits price (base price depends on schema default)" do
      data = {
        "restaurants" => [
          {
            "name" => "No Price Cafe",
            "menus" => [
              { "name" => "lunch", "menu_items" => [ { "name" => "Water" } ] } # no price in payload
            ]
          }
        ]
      }

      run_import!(data)

      r    = Restaurant.find_by!(name: "No Price Cafe")
      m    = r.menus.find_by!(name: "lunch")
      item = r.menu_items.find_by!(name: "Water")
      link = MenuItemization.find_by!(menu: m, menu_item: item)

      # The join intentionally has no pricing if payload omitted price
      expect(link.price_on_menu).to be_nil
      expect(link.currency_on_menu).to be_nil

      # Base item price follows your DB schema (NULL vs default 0.0).
      if db_price_default.present?
        expect(item.price.to_f).to eq(db_price_default.to_f)
      else
        expect(item.price).to be_nil
      end
    end

    it "updates link price/currency when changed in a subsequent import" do
      data = {
        "restaurants" => [
          {
            "name" => "Price Update Cafe",
            "menus" => [
              { "name" => "lunch", "menu_items" => [ { "name" => "Soup", "price" => 4.00, "currency" => "USD" } ] }
            ]
          }
        ]
      }

      # initial
      run_import!(data)

      r    = Restaurant.find_by!(name: "Price Update Cafe")
      m    = r.menus.find_by!(name: "lunch")
      soup = r.menu_items.find_by!(name: "Soup")
      link = MenuItemization.find_by!(menu: m, menu_item: soup)
      expect(link.price_on_menu).to    eq(4.00)
      expect(link.currency_on_menu).to eq("USD")

      # change price + currency
      data2 = {
        "restaurants" => [
          {
            "name" => "Price Update Cafe",
            "menus" => [
              { "name" => "lunch", "menu_items" => [ { "name" => "Soup", "price" => 5.25, "currency" => "EUR" } ] }
            ]
          }
        ]
      }

      result2 = run_import!(data2)
      expect(result2.links_updated).to be >= 1

      link.reload
      expect(link.price_on_menu).to    eq(5.25)
      expect(link.currency_on_menu).to eq("EUR")
    end

    it "tolerates nil/blank currency on incoming data by falling back to item/base or USD when price is present" do
      data = {
        "restaurants" => [
          {
            "name" => "Fallback Currency House",
            "menus" => [
              { "name" => "lunch", "menu_items" => [ { "name" => "Sandwich", "price" => 7.00, "currency" => nil } ] }
            ]
          }
        ]
      }

      run_import!(data)

      r     = Restaurant.find_by!(name: "Fallback Currency House")
      m     = r.menus.find_by!(name: "lunch")
      item  = r.menu_items.find_by!(name: "Sandwich")
      link  = MenuItemization.find_by!(menu: m, menu_item: item)

      expect(link.price_on_menu).to    eq(7.00)
      expect(link.currency_on_menu).to eq("USD")
    end
  end
end
