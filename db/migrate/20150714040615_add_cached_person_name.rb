class AddCachedPersonName < ActiveRecord::Migration
  def change
    add_column :people, :cached, :text
  end
end
