class TweakSerialChron < ActiveRecord::Migration
  def change
    add_column :serial_chronologies, :type, :string
  end
end
