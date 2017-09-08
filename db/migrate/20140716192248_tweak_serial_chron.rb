class TweakSerialChron < ActiveRecord::Migration[4.2]
  def change
    add_column :serial_chronologies, :type, :string
  end
end
