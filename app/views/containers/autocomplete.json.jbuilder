json.array! @containers do |c|
  json.id c.id
  json.label c.id 
  json.gid c.to_global_id.to_s
  json.label_html c.id 

  json.response_values do 
    if params[:method]
      json.set! params[:method], c.id
    end
  end 
end
