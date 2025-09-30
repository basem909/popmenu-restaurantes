class AddPageAuthToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :page_auth, :jsonb, null: false, default: []
    add_index  :users, :page_auth, using: :gin
  end
end
