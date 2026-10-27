json.array! @documents do |s|
  v = document_tag(s)
  json.id s.id
  json.label v
  json.label_html document_autocomplete_tag(s, params[:term])

  json.response_values do 
    if params[:method]
      json.set! params[:method], s.id
    end
  end 
end
