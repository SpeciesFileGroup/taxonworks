class CreateContainers < ActiveRecord::Migration[4.2]
  def change
    create_table :containers do |t|
      t.references :container_type_id, index: true

      t.timestamps
    end
  end
end
