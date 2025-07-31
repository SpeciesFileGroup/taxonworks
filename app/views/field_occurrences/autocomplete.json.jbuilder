json.array! @field_occurrences do |p|
  json.id p.id
  json.label label_for_field_occurrence(p)
  json.label_html field_occurrence_autocomplete_tag(p)

  json.object_id p.id

  json.response_values do
    if params[:method]
      json.set! params[:method], p.id
    end
  end
end
