json.array! @taxon_names do |t|
  json.id t.id
  json.valid_taxon_name_id t.cached_valid_taxon_name_id
  json.label taxon_name_autocomplete_selected_tag(t)
  json.label_html taxon_name_autocomplete_tag(t, params[:term]) 

  json.response_values do 
    if params[:method]
      json.set! params[:method], t.id
    end
  end
end

