class RenameGeoreferenceRequestRequestApi < ActiveRecord::Migration
  def change
    rename_column :georeferences, :request, :api_request
  end
end
