class AddIndexToControlledVocabularyTermAttributeSubjectId < ActiveRecord::Migration[6.0]
  def change
    add_index :data_attributes, :attribute_subject_id
  end
end
