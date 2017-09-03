class ChangeColumnDataAttributesValueToText < ActiveRecord::Migration[4.2]
  def change
    change_column :data_attributes, :value, :text
  end
end
