class RenameLoanItemCollectionObjectStatusToDisposition < ActiveRecord::Migration[4.2]
  # non reversable, assumes no-prior data!
  def change
    remove_column :loan_items, :collection_object_status
    add_column :loan_items, :disposition, :string, index: true
  end
end
