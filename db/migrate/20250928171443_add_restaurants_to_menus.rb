class AddRestaurantsToMenus < ActiveRecord::Migration[7.2]
  def change
    add_reference :menus, :restaurant, null: false, type: :uuid, foreign_key: true, index: true
  end
end
