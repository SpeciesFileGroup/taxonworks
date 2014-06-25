class UpdateSerialChronologiesHousekeepingNames < ActiveRecord::Migration
  def change
   remove_column :serial_chronologies, :modified_by_id
   add_column :serial_chronologies, :updated_by_id, :integer, index: true
  end
end
