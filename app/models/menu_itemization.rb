class MenuItemization < ApplicationRecord
  belongs_to :menu
  belongs_to :menu_item

  validates :menu_id, uniqueness: { scope: :menu_item_id }

  validates :price_on_menu, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :currency_on_menu, presence: true, if: -> { price_on_menu.present? }

  validate  :same_restaurant

  before_validation :normalize_currency_on_menu

  private

  def same_restaurant
    return if menu.blank? || menu_item.blank?
    if menu.restaurant_id != menu_item.restaurant_id
      errors.add(:base, "Menu and MenuItem must belong to the same restaurant")
    end
  end

  def normalize_currency_on_menu
    return if currency_on_menu.nil?
    self.currency_on_menu = currency_on_menu.to_s.strip.upcase.presence
  end
end
