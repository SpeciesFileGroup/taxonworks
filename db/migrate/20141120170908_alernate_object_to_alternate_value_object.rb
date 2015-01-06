class AlernateObjectToAlternateValueObject < ActiveRecord::Migration
  def change
    # rename_column :alternate_values, :alternate_object_attribute, :alternate_value_object_attribute
    remove_column(:alternate_values, :alternate_object_attribute)
    add_column(:alternate_values, :alternate_value_object_attribute, :string)
    # rename_column :alternate_values, :alternate_object_id, :alternate_value_object_id
    remove_column(:alternate_values, :alternate_object_id)
    add_column(:alternate_values, :alternate_value_object_id, :integer)
    # rename_column :alternate_values, :alternate_object_attribute, :alternate_value_object_attribute
    remove_column(:alternate_values, :alternate_object_type)
    add_column(:alternate_values, :alternate_value_object_type, :string)
  end
end
