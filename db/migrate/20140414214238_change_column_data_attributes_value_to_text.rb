class ChangeColumnDataAttributesValueToText < ActiveRecord::Migration
  def change
    change_column :data_attributes, :value, :text
  end
end
