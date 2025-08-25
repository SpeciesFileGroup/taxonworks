json.array! @depictions do |d|
  json.gid d.to_global_id.to_s
  json.id d.id
  json.label label_for_depiction(d)
  json.label_html depiction_autocomplete_tag(d)

  json.response_values do
    if params[:method]
      json.set! params[:method], d.id
    end
  end
end

