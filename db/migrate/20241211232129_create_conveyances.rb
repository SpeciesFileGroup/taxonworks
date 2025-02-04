class CreateConveyances < ActiveRecord::Migration[7.2]
  def change
    create_table :conveyances do |t|
      t.references :sound, foreign_key: true, null: false
      t.references :conveyance_object, polymorphic: true, null: false
      t.references :project, foreign_key: true, null: false
      t.integer :position, null: false, index: true
      t.bigint :created_by_id, null: false, index: true
      t.bigint :updated_by_id, null: false, index: true

      t.timestamps
    end

    add_foreign_key :conveyances, :users, column: :created_by_id
    add_foreign_key :conveyances, :users, column: :updated_by_id
  end
end
