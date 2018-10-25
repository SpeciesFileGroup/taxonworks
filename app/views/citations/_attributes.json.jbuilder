json.extract! citation, :id, :citation_object_id, :citation_object_type, :source_id, :pages, :is_original,
  :created_by_id, :updated_by_id, :project_id
json.partial! '/shared/data/all/metadata', object: citation

json.citation_object do
  if @verbose_object
    path = citation.citation_object_type.tableize
    object = path.singularize.to_sym
    json.partial! "/#{path}/attributes", { object => citation.citation_object }
  else
    json.partial! '/shared/data/all/metadata', object: citation.citation_object
  end
end

json.citation_topics do |ct|
  ct.array! citation.citation_topics, partial: '/citation_topics/attributes', as: :citation_topic
end

json.citation_source_body citation_source_body(citation)
json.source do
  json.partial! '/sources/attributes', source: citation.source 
  if citation.source.is_bibtex?
    json.author_year citation.source.author_year
  end
end

if citation.target_document
  json.target_document do
    json.document do
      json.partial! '/documents/attributes', document: citation.target_document 
    end
    json.target_page citation.target_document_page
  end
end

