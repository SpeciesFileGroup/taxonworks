json.extract! anatomical_part, :id, :name, :uri, :uri_label, :is_material, :taxonomic_origin_object_id, :taxonomic_origin_object_type, :created_at, :updated_at

json.url anatomical_part_url(anatomical_part, format: :json)

json.partial! '/shared/data/all/metadata', object: anatomical_part
