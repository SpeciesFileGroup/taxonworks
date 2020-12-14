json.extract! source, :id, :serial_id, :address, :annote, :author,
:booktitle, :chapter, :crossref, :edition, :editor,
:howpublished, :institution, :journal, :key, :month, :note,
:number, :organization, :pages, :publisher, :school, :series,
:title, :type, :volume, :doi, :abstract, :copyright, :language,
:stated_year, :verbatim, :cached, :cached_author_string,
:bibtex_type, :created_by_id, :updated_by_id, :cached_nomenclature_date,
:day, :year, :isbn, :issn, :verbatim_contents, :verbatim_keywords,
:language_id, :translator, :year_suffix, :url, :created_at, :updated_at

json.global_id source.to_global_id.to_s

json.source_in_project source_in_project?(source)
json.project_source_id project_source_for_source(source)&.id

if source.is_bibtex?
  json.author_year source.author_year

  json.author_roles(source.author_roles) do |role|
    json.extract! role, :id, :position, :type
    json.partial! '/people/api/v1/brief', person: role.person
  end

  json.editor_roles(source.editor_roles) do |role|
    json.extract! role, :id, :position, :type
    json.partial! '/people/api/v1/brief', person: role.person 
  end
end
