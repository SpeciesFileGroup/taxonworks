json.extract! taxon_determination, :id,
:taxon_determination_object_id, :taxon_determination_object_type,
:otu_id,
:position, :year_made, :month_made, :day_made,
:print_label,
:created_at, :updated_at

json.partial!('/shared/data/all/metadata', object: taxon_determination)

json.object do
  json.partial! '/shared/data/all/metadata', object: taxon_determination.taxon_determination_object, extensions: false
end

json.otu do
  json.partial! '/shared/data/all/metadata', object: taxon_determination.otu, extensions: false
  json.name taxon_determination.otu.name
  json.taxon_name_id taxon_determination.otu.taxon_name_id
end

if taxon_determination.roles.any?
  json.determiner_roles do
    json.array! taxon_determination.determiner_roles.order(:position).each do |role|
      json.extract! role, :id, :position, :type
      case role.agent_type
      when :person
        json.person do
          json.partial! '/people/api/v1/base_attributes', person: role.person
        end
      when :organization
        json.organization do
          json.partial! '/organizations/api/v1/attributes', organization: role.organization, extensions: false
        end
      else
        json.error true
      end
    end
  end
end

if extend_response_with('notes')
  json.notes taxon_determination.notes.each do |n|
    json.text n.text
  end
end
