# Generate shallow routes for annotations based on model properties, like
# otu_citations GET /otus/:otu_id/citations(.:format) citations#index
ApplicationEnumeration.data_models.each do |m|
  ::ANNOTATION_TYPES.each do |t|
    if m.send("has_#{t}?")
      n = m.model_name
      match "/#{n.route_key}/:#{n.param_key}_id/#{t}", to: "#{t}#index", as: "#{n.singular}_#{t}", via: :get, constraints: {format: :json}, defaults: {format: :json}
    end
  end
end
