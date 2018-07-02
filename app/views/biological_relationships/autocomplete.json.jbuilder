json.array! @biological_relationships do |t|
  json.id t.id
  json.label biological_relationship_tag(t)
  json.label_html biological_relationship_tag(t)

  json.response_values do 
    if params[:method]
      json.set! params[:method], t.id
    end
  end 
end

