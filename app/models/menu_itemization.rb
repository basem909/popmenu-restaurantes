class MenuItemization < ApplicationRecord
    belongs_to :menu
    belongs_to :menu_item

    validates :menu_id, uniqueness: { scope: :menu_item_id }
    validate  :same_restaurant

    private

    def same_restaurant
      return unless menu && menu_item
      if menu.restaurant_id != menu_item.restaurant_id
        errors.add(:base, "Menu and MenuItem must belong to the same restaurant")
      end
    end
end
