class UpdateSerialChronologiesHousekeepingNames < ActiveRecord::Migration[4.2]
  def change
   remove_column :serial_chronologies, :modified_by_id
   add_column :serial_chronologies, :updated_by_id, :integer, index: true
  end
end
