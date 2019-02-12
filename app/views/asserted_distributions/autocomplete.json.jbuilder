json.array! @asserted_distributions do |a|
  v = asserted_distribution_tag(a)
  json.id a.id
  json.label v
  json.label_html v 

  json.response_values do 
    if params[:method]
      json.set! params[:method], a.id
    end
  end 
end
