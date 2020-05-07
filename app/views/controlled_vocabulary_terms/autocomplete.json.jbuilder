json.array! @controlled_vocabulary_terms do |c|
  json.extract! c, :id
  json.label c.name
  json.label_html controlled_vocabulary_term_autocomplete_tag(c)

  json.response_values do
    json.set! params[:method], c.id
  end
 
end
