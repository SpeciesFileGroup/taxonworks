# index_dwco_on_project_id (project_id, id) serves every lookup the
# single-column project_id index did.
class RemoveRedundantDwcOccurrencesProjectIdIndex < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  INDEX_NAME = :index_dwc_occurrences_on_project_id

  def up
    remove_index :dwc_occurrences, name: INDEX_NAME, algorithm: :concurrently, if_exists: true
  end

  def down
    add_index :dwc_occurrences, :project_id, name: INDEX_NAME, algorithm: :concurrently, if_not_exists: true
  end
end
