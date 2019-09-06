json.array! @data_attributes do |i|
  v = data_attribute_autocomplete_tag(i)
  
  json.id i.id

  json.label data_attribute_tag(i)
  
  json.label_html v
  json.attribute_subject_global_id i.attribute_subject.to_global_id.to_s

  json.attribute_subject_object_id i.attribute_subject_id
  json.attribute_subject_object_type i.attribute_subject_type

  json.response_values do 
    if params[:method]
      json.set! params[:method], i.id
    end
  end 
end
