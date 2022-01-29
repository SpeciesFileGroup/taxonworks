[:collecting_event, :collection_object].each do |t|
  json.set! t do
    json.partial! '/controlled_vocabulary_terms/attributes', as: :controlled_vocabulary_term, collection: 
      Predicate.joins(:internal_attributes)
      .where(
        project_id: sessions_current_project_id, 
        data_attributes: {
          attribute_subject_type: t.to_s.classify
        })
      .order(:id).distinct
  end
end
