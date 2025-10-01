class AddRestaurantIdsToMenuItems < ActiveRecord::Migration[7.2]
  def change
    add_reference :menu_items, :restaurant, null: false, type: :uuid, foreign_key: true, index: true
  end
end
