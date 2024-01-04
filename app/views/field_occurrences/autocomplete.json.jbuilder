json.array! @field_occurences do |p|
  json.id p.id
  json.label field_occurrence_tag(p)
  json.label_html field_occurrence_autocomplete_tag(p)

  json.object_id p.id

  json.response_values do
    if params[:method]
      json.set! params[:method], p.id
    end
  end
end
