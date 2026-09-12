json.array! @asserted_environments do |ae|
  json.id ae.id
  json.uri ae.uri
  json.uri_label ae.uri_label
  json.label label_for_asserted_environment(ae)
  json.label_html asserted_environment_autoselect_tag(ae, params[:term])

  json.response_values do
    if params[:method]
      json.set! params[:method], ae.id
    end
  end
end
