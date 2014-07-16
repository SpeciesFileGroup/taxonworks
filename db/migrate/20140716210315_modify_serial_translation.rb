class ModifySerialTranslation < ActiveRecord::Migration
  def change
    add_column :serials, :translated_from_serial_id, :integer
  end
end
