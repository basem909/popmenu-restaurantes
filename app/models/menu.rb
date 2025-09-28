class Menu < ApplicationRecord
  has_many :menu_items

  validates :name, presence: true

  scope :active, -> { where(active: true) }
end
