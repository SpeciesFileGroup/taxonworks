json.array! @descriptors do |t|
  json.id t.id
  json.label t.name
  json.gid t.to_global_id.to_s 
  json.label_html t.name

  json.response_values do 
    if params[:method]
      json.set! params[:method], t.id
    end
  end 
end
