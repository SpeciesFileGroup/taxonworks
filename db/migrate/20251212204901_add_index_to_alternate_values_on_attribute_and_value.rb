class AddIndexToAlternateValuesOnAttributeAndValue < ActiveRecord::Migration[7.2]
  def change
    add_index :alternate_values, [:alternate_value_object_attribute, :value]
  end
end
