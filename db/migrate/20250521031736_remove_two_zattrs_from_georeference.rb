class RemoveTwoZattrsFromGeoreference < ActiveRecord::Migration[7.2]
  def change
    remove_column :georeferences, :is_undefined_z, :boolean
    remove_column :georeferences, :is_median_z, :boolean
  end
end
