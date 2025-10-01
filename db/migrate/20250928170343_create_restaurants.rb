class CreateRestaurants < ActiveRecord::Migration[7.2]
  def change
    create_table :restaurants, id: :uuid do |t|
      t.string :name, null: false
      t.timestamps
    end
    add_index :restaurants, :name, unique: true
  end
end
