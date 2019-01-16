json.array! @namespaces do |n|
  v = namespace_tag(n)
  json.id n.id
  json.label v
  json.label_html v
  json.short_name n.short_name 

  json.response_values do 
    if params[:method]
      json.set! params[:method], i.id
    end
  end 
end
