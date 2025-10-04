json.extract! anatomical_part, :id, :name, :uri, :uri_label, :is_material, :cached_otu_id, :created_at, :updated_at

json.url anatomical_part_url(anatomical_part, format: :json)

json.partial! '/shared/data/all/metadata', object: anatomical_part
