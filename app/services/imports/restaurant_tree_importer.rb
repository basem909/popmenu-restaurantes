# frozen_string_literal: true

# app/services/imports/restaurant_tree_importer.rb

module Imports
  # Service for importing restaurant data with menus and menu items
  # Handles hierarchical data structure: restaurants -> menus -> menu items
  class RestaurantTreeImporter
    # Result structure to track import statistics and errors
    Result = Struct.new(
      :restaurants_created, :restaurants_found,
      :menus_created, :menus_found,
      :items_created, :items_found,
      :links_created, :links_updated, :links_unchanged,
      :errors,
      keyword_init: true
    ) do
      def to_h
        members.index_with { |member| self[member] }
      end

      def success?
        errors.empty?
      end

      def total_processed
        restaurants_created + restaurants_found + menus_created + menus_found + 
        items_created + items_found + links_created + links_updated + links_unchanged
      end
    end

    def initialize(payload)
      @payload = normalize_payload(payload)
      @result = initialize_result
    end

    # Main entry point for the import process
    def call
      restaurants = extract_restaurants_from_payload
      return @result if restaurants.empty?

      process_restaurants(restaurants)
      log_summary
      @result
    end

    private

    # Initialize result structure with default values
    def initialize_result
      Result.new(
        restaurants_created: 0, restaurants_found: 0,
        menus_created: 0, menus_found: 0,
        items_created: 0, items_found: 0,
        links_created: 0, links_updated: 0, links_unchanged: 0,
        errors: []
      )
    end

    # Extract restaurants from payload and validate
    def extract_restaurants_from_payload
      restaurants = Array(@payload[:restaurants])
      if restaurants.empty?
        @result.errors << "No restaurants provided in the import data"
      end
      restaurants
    end

    # Process all restaurants in the payload
    def process_restaurants(restaurants)
      restaurants.each_with_index do |restaurant_data, restaurant_index|
        import_restaurant!(restaurant_data, restaurant_index)
      end
    end
  
    # ------------------------------------------------------------
    # Restaurant Import Methods
    # ------------------------------------------------------------
    
    # Import a single restaurant with its menus and menu items
    def import_restaurant!(restaurant_data, restaurant_index)
      restaurant_name = extract_restaurant_name(restaurant_data, restaurant_index)
      return if restaurant_name.blank?

      ActiveSupport::Notifications.instrument(
        "imports.restaurant_tree.process_restaurant",
        restaurant: restaurant_name
      ) do
        ActiveRecord::Base.transaction do
          restaurant, created = find_or_create_restaurant!(restaurant_name)
          increment_counter(created ? :restaurants_created : :restaurants_found)

          process_restaurant_menus(restaurant, restaurant_data, restaurant_index)
        rescue ActiveRecord::RecordInvalid => e
          handle_restaurant_validation_error(restaurant_name, e)
          raise ActiveRecord::Rollback
        rescue => e
          handle_restaurant_unexpected_error(restaurant_name, e)
          raise ActiveRecord::Rollback
        end
      end
    end

    # Extract and validate restaurant name
    def extract_restaurant_name(restaurant_data, restaurant_index)
      name = safe_string(restaurant_data[:name])
      if name.blank?
        @result.errors << build_path_error(restaurant_index, :restaurant, "name is required")
      end
      name
    end

    # Process all menus for a restaurant
    def process_restaurant_menus(restaurant, restaurant_data, restaurant_index)
      menus = Array(restaurant_data[:menus])
      return if menus.empty?

      menus.each_with_index do |menu_data, menu_index|
        ActiveSupport::Notifications.instrument(
          "imports.restaurant_tree.process_menu",
          restaurant: restaurant.name,
          menu: menu_data[:name]
        ) do
          import_menu!(restaurant, menu_data, restaurant_index, menu_index)
        end
      end
    end

    # Find existing restaurant or create new one
    def find_or_create_restaurant!(name)
      normalized_name = normalize_name(name)
      existing_restaurant = Restaurant.where("LOWER(name) = ?", normalized_name).first
      
      if existing_restaurant
        [existing_restaurant, false]
      else
        [Restaurant.create!(name: name), true]
      end
    end

    # Handle restaurant validation errors
    def handle_restaurant_validation_error(restaurant_name, error)
      error_message = "Restaurant[#{restaurant_name}]: #{error.record.errors.full_messages.to_sentence}"
      @result.errors << error_message
    end

    # Handle unexpected restaurant errors
    def handle_restaurant_unexpected_error(restaurant_name, error)
      error_message = "Restaurant[#{restaurant_name}] unexpected error: #{error.class}: #{error.message}"
      @result.errors << error_message
      Rails.logger.error(
        message: "imports.restaurant_tree.unexpected_error",
        restaurant: restaurant_name,
        error: error.class.name,
        backtrace: Array(error.backtrace).first(5)
      )
    end
  
    # ------------------------------------------------------------
    # Menu Import Methods
    # ------------------------------------------------------------
    
    # Import a single menu with its menu items
    def import_menu!(restaurant, menu_data, restaurant_index, menu_index)
      menu_name = extract_menu_name(menu_data, restaurant_index, menu_index)
      return if menu_name.blank?

      menu, created = find_or_create_menu!(restaurant, menu_name)
      increment_counter(created ? :menus_created : :menus_found)

      process_menu_items(restaurant, menu, menu_data, restaurant_index, menu_index)
    end

    # Extract and validate menu name
    def extract_menu_name(menu_data, restaurant_index, menu_index)
      menu_name = safe_string(menu_data[:name])
      if menu_name.blank?
        @result.errors << build_path_error(restaurant_index, :menu, "name is required", menu_index: menu_index)
      end
      menu_name
    end

    # Process all menu items for a menu
    def process_menu_items(restaurant, menu, menu_data, restaurant_index, menu_index)
      menu_items = extract_menu_items(menu_data)
      return if menu_items.empty?

      deduplicated_items = deduplicate_menu_items(menu_items, restaurant_index, menu_index)
      process_deduplicated_items(restaurant, menu, deduplicated_items, restaurant_index, menu_index)
    end

    # Extract menu items from menu data (supports both 'menu_items' and 'dishes' keys)
    def extract_menu_items(menu_data)
      Array(menu_data[:menu_items]).presence || Array(menu_data[:dishes])
    end

    # Deduplicate menu items by normalized name (last one wins)
    def deduplicate_menu_items(menu_items, restaurant_index, menu_index)
      deduplicated = {}
      
      menu_items.each_with_index do |item_data, item_index|
        item_name = safe_string(item_data[:name])
        if item_name.blank?
          @result.errors << build_path_error(restaurant_index, :item, "name is required", 
                                           menu_index: menu_index, item_index: item_index)
          next
        end
        
        normalized_name = normalize_name(item_name)
        if deduplicated.key?(normalized_name)
          Rails.logger.info(
            message: "imports.restaurant_tree.duplicate_item",
            restaurant_index: restaurant_index,
            menu_index: menu_index,
            item_name: item_name
          )
        end
        deduplicated[normalized_name] = item_data.merge(name: item_name)
      end
      
      deduplicated.values
    end

    # Process deduplicated menu items
    def process_deduplicated_items(restaurant, menu, items, restaurant_index, menu_index)
      items.each_with_index do |item_data, item_index|
        ActiveSupport::Notifications.instrument(
          "imports.restaurant_tree.process_item",
          restaurant: restaurant.name,
          menu: menu.name,
          item: item_data[:name]
        ) do
          import_item_on_menu!(restaurant, menu, item_data, restaurant_index, menu_index, item_index)
        end
      end
    end

    # Find existing menu or create new one
    def find_or_create_menu!(restaurant, name)
      normalized_name = normalize_name(name)
      existing_menu = restaurant.menus.where("LOWER(name) = ?", normalized_name).first
      
      if existing_menu
        [existing_menu, false]
      else
        [restaurant.menus.create!(name: name), true]
      end
    end
  
    # ------------------------------------------------------------
    # Menu Item Import Methods
    # ------------------------------------------------------------
    
    # Import a single menu item and create/update its menu association
    def import_item_on_menu!(restaurant, menu, item_data, restaurant_index, menu_index, item_index)
      item_name = item_data[:name]
      price_on_menu = parse_price(item_data[:price])
      currency_on_menu = safe_string(item_data[:currency])

      item, created = find_or_create_item!(restaurant, item_name, price_on_menu, currency_on_menu)
      increment_counter(created ? :items_created : :items_found)

      upsert_menu_item_link!(menu, item, price_on_menu, currency_on_menu)
    rescue ActiveRecord::RecordInvalid => e
      error_message = build_path_error(restaurant_index, :item, e.record.errors.full_messages.to_sentence, 
                                     menu_index: menu_index, item_index: item_index)
      @result.errors << error_message
    rescue => e
      error_message = build_path_error(restaurant_index, :item, "unexpected error: #{e.class}: #{e.message}", 
                                     menu_index: menu_index, item_index: item_index)
      @result.errors << error_message
    end

    # Find existing menu item or create new one
    def find_or_create_item!(restaurant, name, price_on_menu, currency_on_menu)
      normalized_name = normalize_name(name)
      existing_item = restaurant.menu_items.where("LOWER(name) = ?", normalized_name).first
      
      if existing_item
        [existing_item, false]
      else
        item_attributes = build_item_attributes(restaurant, name, price_on_menu, currency_on_menu)
        [restaurant.menu_items.create!(item_attributes), true]
      end
    end

    # Build attributes for creating a new menu item
    def build_item_attributes(restaurant, name, price_on_menu, currency_on_menu)
      attributes = { name: name, restaurant_id: restaurant.id }
      
      if price_on_menu
        attributes[:price] = price_on_menu
        attributes[:currency] = currency_on_menu.presence || "USD"
      end
      
      attributes
    end

    # Create or update menu item association with pricing
    def upsert_menu_item_link!(menu, item, price_on_menu, currency_on_menu)
      link = MenuItemization.find_or_initialize_by(menu_id: menu.id, menu_item_id: item.id)
      
      desired_price = price_on_menu
      desired_currency = determine_currency(price_on_menu, currency_on_menu, item)

      if link.new_record?
        create_new_link!(link, desired_price, desired_currency)
      else
        update_existing_link!(link, desired_price, desired_currency)
      end
    end

    # Determine the appropriate currency for the menu item
    def determine_currency(price_on_menu, currency_on_menu, item)
      return nil unless price_on_menu
      currency_on_menu.presence || item.currency || "USD"
    end

    # Create a new menu item link
    def create_new_link!(link, price, currency)
      link.price_on_menu = price
      link.currency_on_menu = currency
      link.save!
      increment_counter(:links_created)
    end

    # Update an existing menu item link if needed
    def update_existing_link!(link, desired_price, desired_currency)
      price_changed = link.price_on_menu != desired_price
      currency_changed = link.currency_on_menu != desired_currency

      if price_changed || currency_changed
        link.price_on_menu = desired_price if price_changed
        link.currency_on_menu = desired_currency if currency_changed
        link.save!
        increment_counter(:links_updated)
      else
        increment_counter(:links_unchanged)
      end
    end
  
    # ------------------------------------------------------------
    # Utility Methods
    # ------------------------------------------------------------
    
    # Increment a counter in the result
    def increment_counter(counter_symbol)
      @result[counter_symbol] = @result[counter_symbol] + 1
    end

    # Normalize input payload to consistent format
    def normalize_payload(payload)
      parsed_payload = case payload
                      when String then JSON.parse(payload)
                      when Hash   then payload
                      else             {}
                      end
      deep_symbolize_keys(parsed_payload)
    end

    # Recursively convert hash keys to symbols
    def deep_symbolize_keys(obj)
      case obj
      when Hash
        obj.each_with_object({}) do |(key, value), result|
          symbol_key = key.to_s.underscore.to_sym
          result[symbol_key] = deep_symbolize_keys(value)
        end
      when Array
        obj.map { |element| deep_symbolize_keys(element) }
      else
        obj
      end
    end

    # Normalize name for consistent comparison
    def normalize_name(name_string)
      name_string.to_s.downcase.squish
    end

    # Safely convert value to string and clean it
    def safe_string(value)
      string_value = value.is_a?(String) ? value : (value.nil? ? "" : value.to_s)
      string_value.squish
    end

    # Parse price value from various formats
    def parse_price(value)
      return nil if value.nil?

      case value
      when Numeric
        value.to_f
      when String
        stripped_value = value.strip
        return nil if stripped_value.blank?
        Float(stripped_value)
      else
        nil
      end
    rescue ArgumentError
      nil
    end

    def log_summary
      Rails.logger.info(
        message: "imports.restaurant_tree.completed",
        stats: @result.to_h,
        success: @result.success?
      )
    end

    # Build descriptive error path for debugging
    def build_path_error(restaurant_index, node_type, message, menu_index: nil, item_index: nil)
      path_parts = ["restaurant[#{restaurant_index}]"]
      path_parts << "menu[#{menu_index}]" if menu_index
      path_parts << "item[#{item_index}]" if item_index
      
      "#{path_parts.join(' > ')} #{node_type}: #{message}"
    end
  end
end
  
