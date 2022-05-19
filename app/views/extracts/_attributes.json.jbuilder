json.extract! extract, :id,
:verbatim_anatomical_origin,
:repository_id,
:year_made, :month_made, :day_made,
:created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object: extract

# TODO: move to shared and use extend
if extract.extractor_roles.any?
  json.extractor_roles(extract.extractor_roles) do |role|
    json.extract! role, :id, :position, :type
    json.person do
      json.partial! '/people/base_attributes', person: role.person
    end
  end
end

if extend_response_with('identifiers')
  json.identifiers do
    json.array! extract.identifiers.pluck(:cached)
  end
end

if extend_response_with('otus')
  json.otus do
    json.array! extract.referenced_otus.collect{|o| label_for(o)}
  end
end
