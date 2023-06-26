json.partial!('/taxon_names/api/v1/base_attributes', taxon_name:)
json.original_combination full_original_taxon_name_tag(taxon_name) # contains HTML

if extend_response_with('parent')
  if taxon_name.parent
    json.parent do |parent|
      json.extract! taxon_name.parent, :id
      json.partial! '/taxon_names/api/v1/base_attributes', taxon_name: taxon_name.parent
    end
  end
end

if extend_response_with('otus')
  if taxon_name.otus
    json.otus do
      json.array!(taxon_name.otus) do |otu|
        json.partial! '/otus/api/v1/attributes', otu:
      end
    end
  end
end

if extend_response_with('roles')
  if taxon_name.roles.any?
    json.taxon_name_author_roles do
      json.array! taxon_name.taxon_name_author_roles.each do |role|
        json.extract! role, :id, :position, :type
        json.partial! '/people/api/v1/brief', person: role.person
      end
    end
  end
end

if extend_response_with('ancestor_ids')
  json.ancestor_ids do
    json.array! taxon_name.ancestors.pluck(:id, :rank_class)
  end
end

if extend_response_with('children')
  if taxon_name.children.any?
    json.children do
      json.array! taxon_name.children.pluck(:id)
    end
  end
end

if extend_response_with('type_taxon_name_relationship')
  unless taxon_name.is_a?(Combination)
    json.type_taxon_name_relationship do
      if taxon_name.type_taxon_name_relationship
        json.partial! '/taxon_name_relationships/attributes', taxon_name_relationship: taxon_name.type_taxon_name_relationship
      end
    end
  end
end
