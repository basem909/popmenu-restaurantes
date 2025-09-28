require "rails_helper"

RSpec.describe MenuItemization, type: :model do
  it "validates uniqueness of [menu_id, menu_item_id]" do
    r = create(:restaurant)
    m = create(:menu, restaurant: r)
    i = create(:menu_item, restaurant: r)
    create(:menu_itemization, menu: m, menu_item: i)
    dup = build(:menu_itemization, menu: m, menu_item: i)

    expect(dup).not_to be_valid
  end

  it "rejects linking across restaurants" do
    r1 = create(:restaurant)
    r2 = create(:restaurant)
    m = create(:menu, restaurant: r1)
    i = create(:menu_item, restaurant: r2)
    bad = build(:menu_itemization, menu: m, menu_item: i)

    expect(bad).not_to be_valid
    expect(bad.errors[:base]).to include("Menu and MenuItem must belong to the same restaurant")
  end
end
