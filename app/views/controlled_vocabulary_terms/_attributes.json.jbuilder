json.extract! controlled_vocabulary_term, :id, :type, :name, :definition, :uri, :uri_relation, :css_color, :updated_at
json.partial! '/shared/data/all/metadata', object: controlled_vocabulary_term

#if params[:count]
if extend_response_with('controlled_vocabulary_use_count')
  json.count case controlled_vocabulary_term.type  
  when 'Keyword'
    controlled_vocabulary_term.tags.count
  when 'ConfidenceLevel'
    controlled_vocabulary_term.confidences.count
  when 'Topic'
    controlled_vocabulary_term.contents.count + controlled_vocabulary_term.citations.count
  when 'Predicate'
    controlled_vocabulary_term.internal_attributes.count
  when 'BiologicalProperty'
    controlled_vocabulary_term.biological_relationship_types.count
  when 'BiocurationGroup'
    controlled_vocabulary_term.tags.count
  when 'BiocurationClass'
    controlled_vocabulary_term.biocuration_classifications.count
  else
    nil 
  end
end
