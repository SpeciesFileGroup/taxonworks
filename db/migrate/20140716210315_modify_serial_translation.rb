class ModifySerialTranslation < ActiveRecord::Migration[4.2]
  def change
    add_column :serials, :translated_from_serial_id, :integer
  end
end
