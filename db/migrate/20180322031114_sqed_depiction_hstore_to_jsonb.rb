class SqedDepictionHstoreToJsonb < ActiveRecord::Migration[5.1]
  def change
    change_column :sqed_depictions, :metadata_map, 'jsonb USING CAST(metadata_map AS jsonb)', null: false, default: '{}'
    change_column :sqed_depictions, :specimen_coordinates, 'jsonb USING CAST(specimen_coordinates AS jsonb)', null: false, default: '{}'
  end
end
