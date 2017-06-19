class AddPositionToControlledVocabularyTerm < ActiveRecord::Migration
  def change
    add_column :controlled_vocabulary_terms, :position, :integer
  end
end
