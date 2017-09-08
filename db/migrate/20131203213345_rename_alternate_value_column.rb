class RenameAlternateValueColumn < ActiveRecord::Migration[4.2]
  def change
    rename_column :alternate_values, :alternate_attribute, :alternate_object_attribute
  end
end
