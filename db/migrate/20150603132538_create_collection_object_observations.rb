class CreateCollectionObjectObservations < ActiveRecord::Migration
  def change
    create_table :collection_object_observations do |t|
      t.text :data, index: true
      # t.json :metadata, default: '{}' # wait till jsonb is out
      t.references :project, index: true
      t.integer :created_by_id, index: true
      t.integer :updated_by_id, index: true

      t.timestamps
    end

    CollectionObjectObservation.connection.execute('alter table collection_object_observations alter data set not null;')
    CollectionObjectObservation.connection.execute('alter table collection_object_observations alter project_id set not null;')
    CollectionObjectObservation.connection.execute('alter table collection_object_observations alter created_by_id set not null;')
    CollectionObjectObservation.connection.execute('alter table collection_object_observations alter updated_by_id set not null;')
    CollectionObjectObservation.connection.execute('alter table collection_object_observations alter created_at set not null;')
    CollectionObjectObservation.connection.execute('alter table collection_object_observations alter updated_at set not null;')
  end
end
