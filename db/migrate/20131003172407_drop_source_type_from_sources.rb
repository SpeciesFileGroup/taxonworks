class DropSourceTypeFromSources < ActiveRecord::Migration[4.2]
  def change
    remove_column :sources, :source_type
  end
end
