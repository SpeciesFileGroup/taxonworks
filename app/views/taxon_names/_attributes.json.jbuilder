json.partial! '/taxon_names/base_attributes', taxon_name: taxon_name

if taxon_name.otus
  json.otus do
    json.array!(taxon_name.otus) do |otu|
      json.id otu.id
      json.name otu.name if otu.name
    end
  end
end

# TODO: move to shared
if taxon_name.roles.any?
  json.taxon_name_author_roles do
    json.array! taxon_name.taxon_name_author_roles.each do |role|
      json.extract! role, :id, :position, :type
      json.person do
        json.partial! '/people/base_attributes', person: role.person 
      end
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
    json.partial! '/taxon_names/base_attributes', taxon_name: taxon_name.parent
  end
end

unless taxon_name.is_a?(Combination)
  json.type_taxon_name_relationship do
    if taxon_name.type_taxon_name_relationship
      json.partial! '/taxon_name_relationships/attributes', taxon_name_relationship: taxon_name.type_taxon_name_relationship
    end
  end
end
