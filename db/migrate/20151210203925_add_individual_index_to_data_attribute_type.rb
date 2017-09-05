class AddIndividualIndexToDataAttributeType < ActiveRecord::Migration[4.2]
  def change

    add_index :data_attributes, :attribute_subject_type

  end
end
