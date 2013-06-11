class CreateBiologicalRelationships < ActiveRecord::Migration
  def change
    create_table :biological_relationships do |t|
      t.string :name
      t.boolean :is_transitive
      t.boolean :is_reflexive

      t.timestamps
    end
  end
end
