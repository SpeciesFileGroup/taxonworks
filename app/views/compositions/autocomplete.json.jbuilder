json.array! @compositions do |c|
  json.id c.id
  json.label composition_autocomplete_selected_tag(c)
  json.label_html composition_tag(c)
  json.gid c.to_global_id.to_s
  json.is_community c.is_community?

  json.response_values do
    if params[:method]
      json.set! params[:method], c.id
    end
  end
end
