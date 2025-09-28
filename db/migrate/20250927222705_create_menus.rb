class CreateMenus < ActiveRecord::Migration[7.2]
  def change
    create_table :menus, id: :uuid do |t|
      t.string   :name, null: false
      t.text     :description
      t.boolean  :active, null: false, default: true
      t.datetime :starts_at
      t.datetime :ends_at
      t.timestamps
    end

    add_index :menus, :name
  end
end
