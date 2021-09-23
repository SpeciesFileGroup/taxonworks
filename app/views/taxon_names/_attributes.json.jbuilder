json.partial! '/taxon_names/base_attributes', taxon_name: taxon_name
json.partial! '/shared/data/all/metadata', object: taxon_name, klass: 'TaxonName'

json.original_combination full_original_taxon_name_tag(taxon_name) # contains HTML

if extend_response_with('parent')
  if taxon_name.parent
    json.parent do |parent|
      json.extract! taxon_name.parent, :id
      json.partial! '/shared/data/all/metadata', object: taxon_name.parent, klass: 'TaxonName', extensions: false
    end
  end
end

if extend_response_with('otus')
  if taxon_name.otus
    json.otus do
      json.array!(taxon_name.otus) do |otu|
        json.extract! otu, :id, :name
        json.partial! '/shared/data/all/metadata', object: otu, klass: 'Otu', extensions: false
      end
    end
  end
end

if extend_response_with('roles')
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

