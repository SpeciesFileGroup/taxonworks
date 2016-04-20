class AddMetadataJsonToImport < ActiveRecord::Migration
  def change
    add_column :imports, :metadata_json, :json
  end
end
