json.array! @people do |p|
  json.id p.id
  json.label person_tag(p)
  json.label_html person_autocomplete_tag(p)

  json.object_id p.id # backwards compatability for lookup_person

  json.response_values do
    if params[:method]
      json.set! params[:method], p.id
    end
  end
end
