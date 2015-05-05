class CreateDepictions < ActiveRecord::Migration
  def change
    create_table :depictions do |t|
      t.string :depiction_object_type, index: true
      t.integer :depiction_object_id, index: true
      t.references :image, index: true
      t.integer :created_by_id, index: true
      t.integer :updated_by_id, index: true
      t.references :project, index: true

      t.timestamps

    end
 
    Depiction.connection.execute('alter table depictions alter depiction_object_type set not null;')
    Depiction.connection.execute('alter table depictions alter depiction_object_id set not null;')
    Depiction.connection.execute('alter table depictions alter image_id set not null;')
    Depiction.connection.execute('alter table depictions alter project_id set not null;')
    Depiction.connection.execute('alter table depictions alter created_by_id set not null;')
    Depiction.connection.execute('alter table depictions alter updated_by_id set not null;')
    Depiction.connection.execute('alter table depictions alter created_at set not null;')
    Depiction.connection.execute('alter table depictions alter updated_at set not null;')
  
  end
end
