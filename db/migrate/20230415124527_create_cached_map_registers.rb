class CreateCachedMapRegisters < ActiveRecord::Migration[6.1]
  def change
    create_table :cached_map_registers do |t|
      
      t.references :cached_map_register_object, polymorphic: true, index: true
      t.references :project, index: true, foreign_key: true

      t.timestamps
    end
  end
end
