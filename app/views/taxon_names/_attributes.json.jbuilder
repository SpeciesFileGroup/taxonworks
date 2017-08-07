json.partial! '/taxon_names/base_attributes', taxon_name: taxon_name

if taxon_name.roles.any?
  json.taxon_name_author_roles do
    json.array! taxon_name.taxon_name_author_roles.each do |role|
      json.position role.position
      json.person do
        json.partial! '/people/attributes', person: role.person 
      end
    end
  end
end 


if taxon_name.parent
  json.parent do |parent|
    json.partial! '/taxon_names/base_attributes', taxon_name: taxon_name.parent
  end
end

if taxon_name.origin_citation
  json.origin_citation do
    json.partial! '/citations/attributes', citation: taxon_name.origin_citation
  end
end

if taxon_name.children.any?
  json.children do
    json.array! taxon_name.children.pluck(:id) 
  end
end 

