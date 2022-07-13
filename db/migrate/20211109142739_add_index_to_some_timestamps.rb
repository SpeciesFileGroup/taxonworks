class AddIndexToSomeTimestamps < ActiveRecord::Migration[6.1]
  def change

    # A reminder, don't extend this migration, add a new one

    add_index :controlled_vocabulary_terms, :updated_at
    add_index :controlled_vocabulary_terms, :created_at

    add_index :dwc_occurrences, :updated_at
    add_index :dwc_occurrences, :created_at

    add_index :sources, :updated_at
    add_index :sources, :created_at
   
    add_index :collection_objects, :created_at
    add_index :collection_objects, :updated_at

    add_index :collecting_events, :created_at
    add_index :collecting_events, :updated_at

    add_index :taxon_names, :created_at
    add_index :taxon_names, :updated_at

    add_index :roles, :created_at
    add_index :roles, :updated_at

    add_index :identifiers, :created_at
    add_index :identifiers, :updated_at

    add_index :tags, :created_at
    add_index :tags, :updated_at
  
    add_index :namespaces, :created_at
    add_index :namespaces, :updated_at
  end
end
