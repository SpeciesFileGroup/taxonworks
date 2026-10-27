json.extract! controlled_vocabulary_term, :id, :type, :name, :definition, :uri, :uri_relation, :css_color, :updated_at

if extend_response_with('alternate_values')
  json.alternate_values controlled_vocabulary_term.alternate_values do |alternate_value|
    json.partial! '/alternate_values/api/v1/attributes', alternate_value:
  end
end
