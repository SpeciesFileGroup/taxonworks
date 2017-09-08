class AddSameAsUriToControlledVocabularyTerm < ActiveRecord::Migration[4.2]
  def change
    add_column :controlled_vocabulary_terms, :same_as_uri, :string
  end
end
