class AddMetadataJSONToImport < ActiveRecord::Migration[4.2]
  def change
    add_column :imports, :metadata_json, :json
  end
end
