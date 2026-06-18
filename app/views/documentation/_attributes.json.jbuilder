json.extract! documentation, :id, :documentation_object_id, :documentation_object_type, :document_id, :project_id, :created_by_id, :updated_by_id, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object: documentation

json.document do
  json.file_url documentation.document.document_file.url() # TODO: REDACT IN PUBLIC
  json.document_file_content_type documentation.document.document_file_content_type
  json.is_public documentation.document.is_public
  json.partial! '/shared/data/all/metadata', object: documentation.document
end

if extend_response_with('annotated_object')
  json.annotated_object do
    json.partial! '/shared/data/all/metadata', object: metamorphosize_if(documentation.documentation_object), extensions: false
  end
end


