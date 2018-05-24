json.set! :types do

  json.set! :tags do
    json.label 'Tags'
    json.klass 'Tag'
    json.url tags_url
    json.select_options_url select_options_keywords_url
    json.all_select_option_url '/controlled_vocabulary_terms.json?of_type[]=Keyword'
    json.total Tag.where(project_id: sessions_current_project_id).count
    ar = Tag.where(project_id: sessions_current_project_id).select(:tag_object_type).distinct.order(:tag_object_type).pluck(:tag_object_type)
    json.used_on klass_and_labels(ar)
  end

  json.set! :confidences do
    json.label 'Confidences'
    json.klass 'Confidence'
    json.url confidences_url
    json.select_options_url select_options_confidence_levels_url
    json.all_select_option_url '/controlled_vocabulary_terms.json?of_type[]=Keyword'
    json.total Confidence.where(project_id: sessions_current_project_id).count
    ar = Confidence.where(project_id: sessions_current_project_id).select(:confidence_object_type).distinct.order(:confidence_object_type).pluck(:confidence_object_type)
    json.used_on klass_and_labels(ar)
  end

  json.set! :data_attributes do
    json.label 'Data attributes'
    json.klass 'DataAttribute'
    json.url data_attributes_url
    json.select_options_url select_options_predicates_url
    json.all_select_option_url '/controlled_vocabulary_terms.json?of_type[]=Predicate'
    json.total DataAttribute.where(project_id: sessions_current_project_id).count
    ar = DataAttribute.where(project_id: sessions_current_project_id).select(:attribute_subject_type).distinct.order(:attribute_subject_type).pluck(:attribute_subject_type)
    json.used_on klass_and_labels(ar)
  end

  json.set! :alternate_values do
    json.label 'Alternate values'
    json.klass 'AlternateValue'
    json.url alternate_values_url
    json.total AlternateValue.where(project_id: sessions_current_project_id).count
    ar = AlternateValue.where(project_id: sessions_current_project_id).select(:alternate_value_object_type).distinct.order(:alternate_value_object_type).pluck(:alternate_value_object_type)
    json.used_on ar
    json.used_on klass_and_labels(ar)
  end

  json.set! :notes do
    json.label 'Notes'
    json.klass 'Note'
    json.url notes_url
    # json.select_options_url select_options_notes_url
    # json.all_select_option_url '/controlled_vocabulary_terms.json?of_type[]=Keyword'
    json.total Note.where(project_id: sessions_current_project_id).count
    ar = Note.where(project_id: sessions_current_project_id).select(:note_object_type).distinct.order(:note_object_type).pluck(:note_object_type)
    json.used_on klass_and_labels(ar)
  end

end
