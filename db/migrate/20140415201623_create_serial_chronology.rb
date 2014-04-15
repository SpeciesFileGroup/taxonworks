class CreateSerialChronology < ActiveRecord::Migration
  def change
    create_table :serial_chronologies do |t|
      t.references :preceding_serial
      t.references :succeeding_serial
      t.integer :created_by_id
      t.integer :modified_by_id
      t.timestamps
    end
    # not project based so no project_id
  end
end
