json.array! @gazetteers do |g|
  json.gid g.to_global_id.to_s
  json.id g.id
  json.label label_for_gazetteer(g)
  json.label_html gazetteer_autocomplete_tag(g)

  json.response_values do
    if params[:method]
      json.set! params[:method], g.id
    end
  end
end