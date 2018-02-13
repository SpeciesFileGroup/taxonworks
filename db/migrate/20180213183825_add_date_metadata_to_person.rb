class AddDateMetadataToPerson < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :year_born, :integer, size: 4
    add_column :people, :year_died, :integer, size: 4
    add_column :people, :year_active_start, :integer, size: 4
    add_column :people, :year_active_end, :integer, size: 4
  end
end
