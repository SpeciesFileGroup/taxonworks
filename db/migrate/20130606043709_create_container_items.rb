class CreateContainerItems < ActiveRecord::Migration[4.2]
  def change
    create_table :container_items do |t|
      t.references :container, index: true
      t.references :otu, index: true
      t.integer :position

      t.timestamps
    end
  end
end
