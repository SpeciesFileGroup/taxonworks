citation_includes = [{citation_topics: :topic}, :topics, :source]

nested_taxon_name_includes = [:source, {citations: citation_includes}]

monograph_includes = [
  :source,
  {origin_citation: citation_includes},
  {citations: citation_includes},
  :taxon_name_classifications,
  {related_taxon_name_relationships: [
    {citations: citation_includes},
    {subject_taxon_name: nested_taxon_name_includes}
  ]},
  {taxon_name_relationships: [
    {citations: citation_includes},
    {object_taxon_name: nested_taxon_name_includes}
  ]}
]

if @descendants_scope
  json.array!(@descendants_scope.includes(monograph_includes)) do |taxon_name|
    json.partial! '/taxon_names/api/v1/monograph_item', taxon_name: taxon_name
  end
else
  json.partial! '/taxon_names/api/v1/monograph_item', taxon_name: @taxon_name_scope.includes(monograph_includes).first
end
