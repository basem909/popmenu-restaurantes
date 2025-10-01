# Represents a restaurant and its related menus and menu items.
class Restaurant < ApplicationRecord
  has_many :menus,      dependent: :destroy
  has_many :menu_items, dependent: :destroy

  validates :name,
            presence: true,
            length: { maximum: 255 },
            uniqueness: { case_sensitive: false }
end
