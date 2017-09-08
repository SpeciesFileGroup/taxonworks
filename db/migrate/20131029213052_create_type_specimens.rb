class CreateTypeSpecimens < ActiveRecord::Migration[4.2]
  def change
    create_table :type_specimens do |t|
      t.references :biological_object, index: true
      t.references :taxon_name, index: true
      t.string :type_type
      t.timestamps
    end
  end
end
