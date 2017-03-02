json.extract! controlled_vocabulary_term, :id, :type, :name, :definition, :uri, :uri_relation, :css_color
json.object_tag controlled_vocabulary_term_tag(controlled_vocabulary_term)
json.url controlled_vocabulary_term_url(controlled_vocabulary_term, format: :json)
