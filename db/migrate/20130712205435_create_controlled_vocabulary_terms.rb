class CreateControlledVocabularyTerms < ActiveRecord::Migration[4.2]
  def change
    create_table :controlled_vocabulary_terms do |t|
      t.string :type
      t.string :name
      t.text :definition

      t.timestamps
    end
  end
end
