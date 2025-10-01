class MovePricingToItemization < ActiveRecord::Migration[7.2]
  def change
    add_column :menu_itemizations, :price_on_menu, :decimal, precision: 10, scale: 2
    add_column :menu_itemizations, :currency_on_menu, :string

    add_index :menu_itemizations, [ :menu_id, :menu_item_id ], unique: true

    add_foreign_key :menu_itemizations, :menus, on_delete: :cascade unless foreign_key_exists?(:menu_itemizations, :menus)
    add_foreign_key :menu_itemizations, :menu_items, on_delete: :cascade unless foreign_key_exists?(:menu_itemizations, :menu_items)
  end
end
