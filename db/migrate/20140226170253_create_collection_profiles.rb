class CreateCollectionProfiles < ActiveRecord::Migration
  def change
    create_table :collection_profiles do |t|
      t.references :container, index: true
      t.references :otu, index: true
      t.integer :conservation_status
      t.integer :processing_state
      t.integer :container_condition
      t.integer :condition_of_labels
      t.integer :identification_level
      t.integer :arrangement_level
      t.integer :data_quality
      t.integer :computerization_level
      t.integer :number_of_collection_objects
      t.integer :number_of_containers
      t.integer :created_by_id
      t.integer :modified_by_id
      t.integer :project_id

      t.timestamps
    end
  end
end
