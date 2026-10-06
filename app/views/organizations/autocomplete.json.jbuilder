json.array! @organizations do |t|
  json.id t.id
  json.label t.name 
  json.label_html organization_autocomplete_tag(t, params[:term])
  json.gid t.to_global_id.to_s

  json.response_values do 
    if params[:method]
      json.set! params[:method], t.id
    end
  end 
end

