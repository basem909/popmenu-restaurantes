class CreateMenuItemizations < ActiveRecord::Migration[7.2]
  def change
    create_table :menu_itemizations, id: :uuid do |t|
      t.references :menu,      null: false, type: :uuid, foreign_key: true, index: true
      t.references :menu_item, null: false, type: :uuid, foreign_key: true, index: true
      t.timestamps
    end

    add_index :menu_itemizations, [ :menu_id, :menu_item_id ], unique: true, name: "index_menu_itemizations_on_menu_and_item"
  end
end
