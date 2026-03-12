json.array! @preparation_types do |p|
  json.gid p.to_global_id.to_s
  json.id p.id
  json.label label_for_preparation_type(p)
  json.label_html preparation_type_autocomplete_tag(p)

  json.response_values do
    if params[:method]
      json.set! params[:method], p.id
    end
  end
end