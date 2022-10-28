json.extract! taxon_determination, :id, :biological_collection_object_id, :otu_id, 
  :position, :year_made, :month_made, :day_made,
  :print_label,
  :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object: taxon_determination

json.collection_object do
  json.partial! '/shared/data/all/metadata', object: taxon_determination.biological_collection_object, extensions: false
end

json.otu do
  json.partial! '/shared/data/all/metadata', object: taxon_determination.otu, extensions: false
  json.taxon_name_id taxon_determination.otu.taxon_name_id
end

if taxon_determination.roles.any?
  json.determiner_roles do
    json.array! taxon_determination.determiner_roles.order(:position).each do |role|
      json.extract! role, :id, :position, :type
      case role.agent_type
      when :person
        json.person do
          json.partial! '/people/base_attributes', person: role.person
        end
      when :organization
        json.organization do
          json.partial! '/organizations/attributes', organization: role.organization
        end
      else
        json.error true
      end
    end
  end
end