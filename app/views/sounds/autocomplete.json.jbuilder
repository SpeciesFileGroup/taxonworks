json.array! @sounds do |t|
  json.id t.id
  json.label t.name
  json.label_html sound_tag(t)
  json.gid t.to_global_id.to_s

  json.response_values do 
    if params[:method]
      json.set! params[:method], t.id
    end
  end 
end

