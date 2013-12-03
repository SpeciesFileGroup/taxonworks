class RenameAlternateValueColumns < ActiveRecord::Migration
  def change
    rename_column :alternate_values, :alternate_type, :alternate_object_type
    rename_column :alternate_values, :alternate_id, :alternate_object_id

  end
end
