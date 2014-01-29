class ChangeSourceColumnUrl < ActiveRecord::Migration
  def change
    remove_column :sources, :URL
    add_column :sources, :url, :string  end
end
