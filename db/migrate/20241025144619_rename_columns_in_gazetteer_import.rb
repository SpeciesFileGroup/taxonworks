class RenameColumnsInGazetteerImport < ActiveRecord::Migration[7.1]
  def change
    rename_column :gazetteer_imports, :aborted_reason, :error_messages
    rename_column :gazetteer_imports, :num_records_processed, :num_records_imported
  end
end
