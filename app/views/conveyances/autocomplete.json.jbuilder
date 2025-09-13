json.array! @conveyances do |c|
  json.gid c.to_global_id.to_s
  json.id c.id
  json.label label_for_conveyance(c)
  json.label_html conveyance_autocomplete_tag(c)

  json.response_values do
    if params[:method]
      json.set! params[:method], c.id
    end
  end
end

