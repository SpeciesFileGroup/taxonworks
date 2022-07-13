json.extract! attribution, :id, :copyright_year, :license, :attribution_object_id, :attribution_object_type, :created_at, :updated_at
json.url attribution_url(attribution, format: :json)

json.partial! '/shared/data/all/metadata', object: attribution # , extensions: false

# TODO: use extend to get this Annotation object
# json.annotated_object do
#   json.partial! '/shared/data/all/metadata', object: metamorphosize_if(attribution.attribution_object)
# end

if attribution.roles.load.any?
  ::Attribution::ATTRIBUTION_ROLES.each do |r|
    role = "#{r}_roles"
    if attribution.send(role).any?
      json.set! role do
        json.array! attribution.send(role).order('roles.position ASC') do |role|
          json.extract! role, :id, :position, :type
          json.agent_type role.agent_type
          case role.agent_type
          when :person
            json.person do
              json.partial! '/people/api/v1/base_attributes', person: role.person
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
  end
end
