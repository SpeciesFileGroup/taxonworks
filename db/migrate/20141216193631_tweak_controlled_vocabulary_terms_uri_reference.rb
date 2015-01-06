class TweakControlledVocabularyTermsUriReference < ActiveRecord::Migration
  def change
    remove_column :controlled_vocabulary_terms, :same_as_uri
    add_column :controlled_vocabulary_terms, :uri, :string
    add_column :controlled_vocabulary_terms, :uri_relation, :string
  end
end
