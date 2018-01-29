json.array! @sources do |s|
  json.id s.id
  json.label source_tag(s)
  json.label_html source_tag(s)

  json.response_values do 
    json.set! params[:method], s.id
  end 
end
