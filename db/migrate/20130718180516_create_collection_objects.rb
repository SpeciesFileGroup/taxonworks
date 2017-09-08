class CreateCollectionObjects < ActiveRecord::Migration[4.2]
  def change
    create_table :collection_objects do |t|
      t.integer :total
      t.string :type

      t.timestamps
    end
  end
end
