class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.references :person, index: true
      t.string :type
      t.integer :role_object_id
      t.string :role_object_type
      t.integer :position

      t.timestamps
    end
  end
end
