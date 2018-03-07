class CreateBiologicalProperties < ActiveRecord::Migration[4.2]
  def change
    create_table :biological_properties do |t|
      t.string :name
      t.text :definition

      t.timestamps
    end
  end
end
