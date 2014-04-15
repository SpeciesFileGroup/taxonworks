class AddCurationAttributesToCollectionObjects < ActiveRecord::Migration
  def change
    add_column :collection_objects, :accessioned_at, :date
    add_column :collection_objects, :deaccession_at, :date
    add_column :collection_objects, :accession_provider_id, :integer
    add_column :collection_objects, :deaccession_recipient_id, :integer
    add_column :collection_objects, :deaccession_reason, :string
  end
end
