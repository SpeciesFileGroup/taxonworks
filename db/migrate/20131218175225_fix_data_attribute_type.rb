class FixDataAttributeType < ActiveRecord::Migration
  def change
    change_column :data_attributes, :attribute_subject_type, :string
  end
end
