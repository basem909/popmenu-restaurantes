# app/models/menu_item.rb
class MenuItem < ApplicationRecord
    belongs_to :restaurant

    has_many :menu_itemizations, dependent: :destroy
    has_many :menus, through: :menu_itemizations

    validates :name,  presence: true,
                      length: { maximum: 255 },
                      uniqueness: { scope: :restaurant_id, case_sensitive: false }
    validates :description, length: { maximum: 1000 }, allow_blank: true
    validates :price, numericality: { greater_than_or_equal_to: 0 }

    scope :active, -> { where(active: true) }
end
