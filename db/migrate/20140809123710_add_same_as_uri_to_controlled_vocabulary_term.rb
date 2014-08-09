class AddSameAsUriToControlledVocabularyTerm < ActiveRecord::Migration
  def change
    add_column :controlled_vocabulary_terms, :same_as_uri, :string
  end
end
