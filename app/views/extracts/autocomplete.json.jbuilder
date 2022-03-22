json.array! @extracts do |s|
  v = extract_autocomplete_tag(s)
  json.id s.id
  json.label  label_for_extract(s)
  json.gid s.to_global_id.to_s
  json.label_html v

  json.response_values do 
    if params[:method]
      json.set! params[:method], s.id
    end
  end 
end
