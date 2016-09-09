class AddCssColorToControlledVocabularyTerm < ActiveRecord::Migration
  def change
    add_column :controlled_vocabulary_terms, :css_color, :string
  end
end
