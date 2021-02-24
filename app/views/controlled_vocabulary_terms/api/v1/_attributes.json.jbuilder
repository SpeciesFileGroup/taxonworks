json.extract! controlled_vocabulary_term, :id, :type, :name, :definition, :uri, :uri_relation, :css_color, :updated_at
json.partial! '/shared/data/all/metadata', object: controlled_vocabulary_term
