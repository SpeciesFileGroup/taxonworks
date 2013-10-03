class DropSourceTypeFromSources < ActiveRecord::Migration
  def change
    remove_column :sources, :source_type
  end
end
