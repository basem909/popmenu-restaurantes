module PermittedAttributes
  MENUS       = %i[name description active starts_at ends_at restaurant_id].freeze
  MENU_ITEMS  = %i[name description price currency active restaurant_id].freeze
  RESTAURANTS = %i[name].freeze

  LOOKUP = {
    "menu"        => MENUS,
    "menu_item"   => MENU_ITEMS,
    "restaurant"  => RESTAURANTS
  }.freeze

  def self.for(resource_key)
    (LOOKUP[resource_key.to_s] || []).dup
  end
end
