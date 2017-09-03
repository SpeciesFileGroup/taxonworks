class RenameGeoreferenceRequestRequestApi < ActiveRecord::Migration[4.2]
  def change
    rename_column :georeferences, :request, :api_request
  end
end
