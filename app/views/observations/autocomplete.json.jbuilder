json.array! @observations do |o|
  json.gid o.to_global_id.to_s
  json.id o.id
  json.label label_for_observation(o)
  json.label_html observation_autocomplete_tag(o)

  json.response_values do
    if params[:method]
      json.set! params[:method], o.id
    end
  end
end
