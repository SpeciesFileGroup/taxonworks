class AddIndividualIndexToDataAttributeType < ActiveRecord::Migration
  def change

    add_index :data_attributes, :attribute_subject_type

  end
end
