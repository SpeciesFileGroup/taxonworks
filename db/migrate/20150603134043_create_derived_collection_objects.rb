class CreateDerivedCollectionObjects < ActiveRecord::Migration
  def change
    create_table :derived_collection_objects do |t|
      t.references :collection_object_observation
      t.references :collection_object
      t.integer :position
      t.references :project, index: true
      t.integer :created_by_id
      t.integer :updated_by_id

      t.timestamps
    end

    add_index :derived_collection_objects, :collection_object_observation_id, name: 'dco_collection_object_observation'
    add_index :derived_collection_objects, :collection_object_id, name: 'dco_collection_object'

    DerivedCollectionObject.connection.execute('alter table derived_collection_objects alter collection_object_observation_id set not null;')
    DerivedCollectionObject.connection.execute('alter table derived_collection_objects alter collection_object_id set not null;')
    DerivedCollectionObject.connection.execute('alter table derived_collection_objects alter project_id set not null;')
    DerivedCollectionObject.connection.execute('alter table derived_collection_objects alter created_by_id set not null;')
    DerivedCollectionObject.connection.execute('alter table derived_collection_objects alter updated_by_id set not null;')
    DerivedCollectionObject.connection.execute('alter table derived_collection_objects alter created_at set not null;')
    DerivedCollectionObject.connection.execute('alter table derived_collection_objects alter updated_at set not null;')
  end
end
