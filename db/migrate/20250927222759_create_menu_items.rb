class CreateMenuItems < ActiveRecord::Migration[7.2]
  def change
    create_table :menu_items, id: :uuid do |t|
      t.references :menu, null: false, type: :uuid, foreign_key: true # <- FK to menus
      t.string  :name, null: false
      t.text    :description
      t.decimal :price, precision: 10, scale: 2, null: false, default: 0
      t.string  :currency, null: false, default: "USD"
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    add_index :menu_items, :name
  end
end
