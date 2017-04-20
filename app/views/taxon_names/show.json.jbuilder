json.partial! '/taxon_names/show', taxon_name: @taxon_name

if @taxon_name.parent
  json.parent do |parent|
    json.partial! '/taxon_names/attributes', taxon_name: @taxon_name.parent
  end
end
