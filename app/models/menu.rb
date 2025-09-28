class Menu < ApplicationRecord
  belongs_to :restaurant

  has_many :menu_itemizations, dependent: :destroy
  has_many :menu_items, through: :menu_itemizations

  validates :name, presence: true
  scope :active, -> { where(active: true) }
end
