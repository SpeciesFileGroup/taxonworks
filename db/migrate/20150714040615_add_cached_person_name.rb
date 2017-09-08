class AddCachedPersonName < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :cached, :text
  end
end
