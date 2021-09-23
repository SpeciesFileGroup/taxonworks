json.extract! citation, :id, :citation_object_id, :citation_object_type, :source_id, :pages, :is_original,
  :created_by_id, :updated_by_id, :project_id

json.partial! '/shared/data/all/metadata', object: citation

json.citation_source_body citation_source_body(citation)

if extend_response_with('citation_object')
  json.citation_object do
    json.partial! '/shared/data/all/metadata', object: citation.citation_object, extensions: false
  end
end

if extend_response_with('citation_topics')
  json.citation_topics do |ct|
    ct.array! citation.citation_topics, partial: '/citation_topics/attributes', as: :citation_topic
  end
end

if extend_response_with('source')
  json.source do
    json.partial! '/shared/data/all/metadata', object: citation.source, extensions: false
    if citation.source.is_bibtex?
      json.author_year citation.source.author_year
    end
  end
end

if extend_response_with('target_document')
  if citation.target_document
    json.target_document do
      json.document do
        json.partial! '/documents/attributes', document: citation.target_document
      end
      json.target_page citation.target_document_page
    end
  end
end
