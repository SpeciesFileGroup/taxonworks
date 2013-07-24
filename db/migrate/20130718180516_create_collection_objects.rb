class CreateCollectionObjects < ActiveRecord::Migration
  def change
    create_table :collection_objects do |t|
      t.integer :total
      t.string :type

      t.timestamps
    end
  end
end
