class AddObservationObjectToObservations < ActiveRecord::Migration[6.1]
  def change
    add_column :observations, :observation_object_id, :integer
    add_column :observations, :observation_object_type, :string
    add_index :observations, [:observation_object_id, :observation_object_type], name: 'observation_polymorphic_index'
  end
end
