class AddCssColorToControlledVocabularyTerm < ActiveRecord::Migration[4.2]
  def change
    add_column :controlled_vocabulary_terms, :css_color, :string
  end
end
