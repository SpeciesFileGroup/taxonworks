json.array! @people do |p|
  json.id p.id
  json.label p.name 
  json.label_html p.name 
  json.object_id p.id # backwards compatability for lookup_person

  json.response_values do 
    if params[:method]
      json.set! params[:method], s.id
    end
  end 
end
