json.array! @observation_matrices do |m|
  json.id m.id
  json.label m.name
  json.gid m.to_global_id.to_s 
  json.label_html mark_tag(m.name, params[:term])

  json.response_values do 
    if params[:method]
      json.set! params[:method], m.id
    end
  end 
end
