class MenuItem < ApplicationRecord
    validates :name, presence: true
    validates :price, numericality: { greater_than_or_equal_to: 0 }

    scope :active, -> { where(active: true) }
end
