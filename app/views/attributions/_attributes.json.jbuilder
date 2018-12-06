json.extract! attribution, :id, :copyright_year, :license, :created_at, :updated_at
json.url attribution_url(attribution, format: :json)

json.partial! '/shared/data/all/metadata', object: attribution

json.annotated_object do
  json.partial! '/shared/data/all/metadata', object: metamorphosize_if(attribution.attribution_object)
end

if attribution.roles.any?

  ::Attribution::ATTRIBUTION_ROLES.each do |r|
    role = "#{r}_roles"
    if attribution.send(role).any?
      json.set! role do
        json.array! attribution.send(role).order('roles.position ASC').each do |role|
          json.extract! role, :id, :position, :type
          json.person do
            json.partial! '/people/base_attributes', person: role.person
          end
        end
      end
    end
  end


end
