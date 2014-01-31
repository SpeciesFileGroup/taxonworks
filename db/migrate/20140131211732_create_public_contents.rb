class CreatePublicContents < ActiveRecord::Migration
  def change
    create_table :public_contents do |t|
      t.references :otu, index: true
      t.references :topic, index: true
      t.text :text
      t.integer :version
      t.references :project, index: true
      t.integer :created_by_id
      t.integer :updated_by_id

      t.timestamps
    end
  end
end
