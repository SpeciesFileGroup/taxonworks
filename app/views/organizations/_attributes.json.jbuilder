json.extract! organization, :id, :name, :alternate_name, :description, :disambiguating_description, :same_as_id, :address, :email, :telephone, :duns, :global_location_number, :legal_name, :area_served_id, :department_id, :parent_organization_id
, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object: organization 

