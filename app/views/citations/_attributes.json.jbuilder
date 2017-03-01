json.extract! citation, :id, :citation_object_id, :citation_object_type, :source_id, :pages, :is_original, :created_by_id, :updated_by_id, :project_id
json.source do
  json.cached citation.source.cached 
  json.cached_author_string citation.source.cached_author_string 
  json.cached_nomenclature_date citation.source.cached_nomenclature_date
  if citation.source.is_bibtex?
    json.author_year citation.source.author_year
  end
  json.source_tag object_tag(citation.source)
end
json.url citation_url(citation, format: :json)
