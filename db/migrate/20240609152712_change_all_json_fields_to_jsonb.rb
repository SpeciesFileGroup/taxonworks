class ChangeAllJSONFieldsToJsonb < ActiveRecord::Migration[7.1]
  def change
    reversible do |direction|
      direction.up do
        change_column :imports, :metadata_json, :jsonb, using: 'metadata_json::jsonb'
        change_column :users, :footprints, :jsonb, using: 'footprints::jsonb', default: '{}'
        change_column :users, :hub_favorites, :jsonb, using: 'hub_favorites::jsonb'
        change_column :users, :preferences, :jsonb, using: 'preferences::jsonb', default: '{}'
      end

      direction.down do
        change_column :imports, :metadata_json, :json, using: 'metadata_json::json'
        change_column :users, :footprints, :json, using: 'footprints::json', default: '{}'
        change_column :users, :hub_favorites, :json, using: 'hub_favorites::json'
        change_column :users, :preferences, :json, using: 'preferences::json', default: '{}'
      end
    end
  end
end
