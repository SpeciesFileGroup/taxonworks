json.array! @namespaces do |n|
  json.id n.id
  json.label n.name
  json.label_html namespace_autocomplete_tag(n)
  json.short_name n.short_name

  json.response_values do 
    if params[:method]
      json.set! params[:method], n.id
    end
  end 
end
