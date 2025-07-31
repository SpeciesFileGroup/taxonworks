json.array! @leads do |l|
  json.gid l.to_global_id.to_s
  json.id l.id
  json.label label_for_lead(l)
  json.label_html lead_autocomplete_tag(l)

  json.response_values do
    if params[:method]
      json.set! params[:method], l.id
    end
  end
end