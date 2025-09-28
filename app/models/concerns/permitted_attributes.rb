# frozen_string_literal: true

module PermittedAttributes
    MENUS      = %i[name description active starts_at ends_at].freeze
    MENU_ITEMS = %i[name description price currency active].freeze

    LOOKUP = {
      "menu"      => MENUS,
      "menu_item" => MENU_ITEMS
    }.freeze

    def self.for(resource_key)
      (LOOKUP[resource_key.to_s] || []).dup
    end
end
