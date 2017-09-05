class CreateCitations < ActiveRecord::Migration[4.2]
  def change
    create_table :citations do |t|
      t.string :citation_object_id
      t.string :citation_object_type
      t.integer :source_id

      t.timestamps
    end
  end
end
