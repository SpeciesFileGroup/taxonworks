class RemovePeopleFromCollectionObjects < ActiveRecord::Migration
  def change

    remove_column :collection_objects, :accession_provider_id
    remove_column :collection_objects, :deaccession_recipient_id

  end
end
