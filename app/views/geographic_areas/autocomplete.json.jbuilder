json.array! @geographic_areas do |g|
  json.id g.id
  json.label g.name
  json.label_html geographic_area_autocomplete_tag(g, params[:term])
  json.gid g.to_global_id.to_s

  json.response_values do 
    if params[:method]
      json.set! params[:method], g.id
    end
  end 
end
