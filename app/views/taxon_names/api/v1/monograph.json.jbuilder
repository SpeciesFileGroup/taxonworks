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

if extend_response_with('descendants')
  root = TaxonName.with_project_id(sessions_current_project_id).find(params[:id])

  if root.descendants.count > 2500
    json.array! []
  else
    json.array!(root.descendants.includes(monograph_includes)) do |taxon_name|
      json.partial! '/taxon_names/api/v1/monograph_item', taxon_name: taxon_name
    end
  end
else
  taxon_name = TaxonName.with_project_id(sessions_current_project_id).includes(monograph_includes).find(params[:id])
  json.partial! '/taxon_names/api/v1/monograph_item', taxon_name: taxon_name
end
