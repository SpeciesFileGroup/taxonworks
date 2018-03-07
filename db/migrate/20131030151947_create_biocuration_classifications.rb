class CreateBiocurationClassifications < ActiveRecord::Migration[4.2]
  def change
    create_table :biocuration_classifications do |t|
      t.references :biocuration_class, index: true
      t.references :biological_collection_object
      t.integer :position
      t.timestamps
    end
  end
end
