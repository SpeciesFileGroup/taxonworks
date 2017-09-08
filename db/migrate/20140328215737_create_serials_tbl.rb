class CreateSerialsTbl < ActiveRecord::Migration[4.2]
  def change
    create_table :serials do |t|
      t.string :full_name
      t.integer :created_by_id
      t.integer :updated_by_id
      t.integer :project_id
      t.timestamps

    end
  end
end
