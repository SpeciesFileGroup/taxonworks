class CreateSpecimenContainers < ActiveRecord::Migration[4.2]
  def change
    create_table :specimen_containers do |t|
      t.references :specimen_id, index: true
      t.references :container_id, index: true
      t.integer :position

      t.timestamps
    end
  end
end
