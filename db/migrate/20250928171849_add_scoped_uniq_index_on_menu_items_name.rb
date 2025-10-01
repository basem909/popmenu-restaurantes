class AddScopedUniqIndexOnMenuItemsName < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    remove_index :menu_items, name: "index_menu_items_on_lower_name", algorithm: :concurrently, if_exists: true

    add_index :menu_items,
              "restaurant_id, lower(name)",
              unique: true,
              name: "index_menu_items_on_restaurant_and_lower_name",
              algorithm: :concurrently
  end

  def down
    remove_index :menu_items, name: "index_menu_items_on_restaurant_and_lower_name", algorithm: :concurrently
  end
end
