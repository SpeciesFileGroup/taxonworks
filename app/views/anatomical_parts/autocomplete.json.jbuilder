json.array! @anatomical_parts do |ap|
  json.gid ap.to_global_id.to_s
  json.id ap.id
  json.label label_for_anatomical_part(ap)
  json.label_html anatomical_part_autocomplete_tag(ap)

  json.response_values do
    if params[:method]
      json.set! params[:method], ap.id
    end
  end
end