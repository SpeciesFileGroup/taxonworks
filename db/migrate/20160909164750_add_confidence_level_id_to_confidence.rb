class AddConfidenceLevelIdToConfidence < ActiveRecord::Migration[4.2]
  
  def change
    add_column :confidences, :confidence_level_id, :integer, index: true, null: false
    add_foreign_key :confidences, :controlled_vocabulary_terms, column: :confidence_level_id # , primary_key: "lng_id" 
  end

end
