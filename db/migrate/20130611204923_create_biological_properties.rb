class CreateBiologicalProperties < ActiveRecord::Migration
  def change
    create_table :biological_properties do |t|
      t.string :name
      t.text :definition

      t.timestamps
    end
  end
end
