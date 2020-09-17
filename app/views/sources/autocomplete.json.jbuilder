json.array! @sources do |s|
  v = source_tag(s)
  json.id s.id
  json.label v
  json.label_html sources_autocomplete_tag(s, @term ) 
  json.is_in_project s.is_in_project?(sessions_current_project_id)

  json.response_values do 
    if params[:method]
      json.set! params[:method], s.id
    end
  end 
end
