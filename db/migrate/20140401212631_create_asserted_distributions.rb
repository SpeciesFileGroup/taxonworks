class CreateAssertedDistributions < ActiveRecord::Migration
  def change
    create_table :asserted_distributions do |t|
      t.references :otu, index: true
      t.references :geographic_area, index: true
      t.references :source, index: true
      t.references :project, index: true
      t.integer :created_by_id
      t.integer :updated_by_id

      t.timestamps
    end
  end
end
