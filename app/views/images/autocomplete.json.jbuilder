json.array! @images do |i| 
  json.gid i.to_global_id.to_s
  json.id i.id
  json.label "Image #{i.id}"
  json.label_html image_autocomplete_tag(i)

  json.response_values do 
    if params[:method]
      json.set! params[:method], i.id
    end
  end 
end

