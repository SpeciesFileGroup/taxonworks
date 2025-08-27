json.array! @biological_associations do |b|
  json.id b.id
  json.gid b.to_global_id.to_s

  json.label label_for_biological_association(b)
  json.label_html biological_association_autocomplete_tag(b)

  json.response_values do
    if params[:method]
      json.set! params[:method], b.id
    end
  end
end
