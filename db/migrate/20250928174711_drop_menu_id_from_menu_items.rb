class DropMenuIdFromMenuItems < ActiveRecord::Migration[7.2]
  def change
    remove_reference :menu_items, :menu, type: :uuid, index: true, foreign_key: true
  end
end
