class DataMigrationUpdatePinboardItemTypes < ActiveRecord::Migration[6.0]

  PinboardItem.where(pinned_object_type: ['Keyword', 'Topic', 'Predicate', 'ConfidenceLevel'])
    .update_all(pinned_object_type: 'ControlledVocabularyTerm')
  
end
