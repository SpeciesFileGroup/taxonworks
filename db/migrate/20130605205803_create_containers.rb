class CreateContainers < ActiveRecord::Migration
  def change
    create_table :containers do |t|
      t.references :container_type_id, index: true

      t.timestamps
    end
  end
end
