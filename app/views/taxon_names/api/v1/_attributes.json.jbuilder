json.partial! '/taxon_names/api/v1/base_attributes', taxon_name: taxon_name

if taxon_name.roles.any?
  json.taxon_name_author_roles do
    json.array! taxon_name.taxon_name_author_roles.each do |role|
      json.extract! role, :id, :position
      json.partial! '/people/api/v1/brief', person: role.person
    end
  end
end

json.ancestor_ids do
  json.array! taxon_name.ancestors.pluck(:id, :rank_class)
end

if taxon_name.children.any?
  json.children do
    json.array! taxon_name.children.pluck(:id)
  end
end

if taxon_name.parent
  json.parent do |parent|
    json.partial! '/taxon_names/api/v1/base_attributes', taxon_name: taxon_name.parent
  end
end

unless taxon_name.is_a?(Combination)
  json.type_taxon_name_relationship do
    if taxon_name.type_taxon_name_relationship
      json.partial! '/taxon_name_relationships/api/v1/attributes', taxon_name_relationship: taxon_name.type_taxon_name_relationship
    end
  end
end
