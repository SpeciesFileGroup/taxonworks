class AddPositionToControlledVocabularyTerm < ActiveRecord::Migration[4.2]
  def change
    add_column :controlled_vocabulary_terms, :position, :integer
  end
end
