class ChangeSourceColumnUrl < ActiveRecord::Migration[4.2]
  def change
    remove_column :sources, :URL
    add_column :sources, :url, :string  end
end
