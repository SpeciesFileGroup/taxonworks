json.array! @containers do |c|
  json.id c.id
  json.label label_for_container(c)
  json.gid c.to_global_id.to_s
  json.label_html container_autocomplete_tag(c) 

  json.response_values do 
    if params[:method]
      json.set! params[:method], c.id
    end
  end 
end
