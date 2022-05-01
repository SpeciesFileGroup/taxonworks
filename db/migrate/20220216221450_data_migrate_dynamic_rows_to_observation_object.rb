class DataMigrateDynamicRowsToObservationObject < ActiveRecord::Migration[6.1]
  def change
    ::ObservationMatrixRowItem::Dynamic.find_each do |o|
      if !o.taxon_name_id.nil?
        o.update_columns(
          observation_object_id: o.taxon_name_id,
          observation_object_type: 'TaxonName')
      elsif !o.controlled_vocabulary_term_id.nil?
        o.update_columns(
          observation_object_id: o.controlled_vocabulary_term_id,
          observation_object_type: 'ControlledVocabularyTerm')
      else
        next
      end
    end
  end
end
