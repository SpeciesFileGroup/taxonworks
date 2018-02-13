json.array! @taxon_names do |t|
  json.id t.id
  json.label taxon_name_autocomplete_selected_tag(t)
  json.label_html autocomplete_tag(t, params[:term]) 

  json.response_values do 
    json.set! params[:method], t.id
  end 
end

