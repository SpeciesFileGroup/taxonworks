class SqedDepictionHstoreToJsonb < ActiveRecord::Migration[5.1]
  def change
    change_column :sqed_depictions, :metadata_map, :jsonb, using: 'metadata_map::jsonb', null: false, default: '{}'
    change_column :sqed_depictions, :specimen_coordinates, :jsonb, using: 'specimen_coordinates::jsonb', null: false, default: '{}'
  end
end
