json.array! @otus do |t|
  json.id t.id
  json.label otu_autocomplete_selected_tag(t)
  json.label_html otu_tag(t)
  json.gid t.to_global_id.to_s

  json.response_values do 
    if params[:method]
      json.set! params[:method], t.id
    end
  end 
end

