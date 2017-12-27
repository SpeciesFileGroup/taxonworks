json.extract! preparation_type, :id, :name, :definition, :created_by_id, :updated_by_id, :created_at, :updated_at
json.partial! '/shared/data/all/metadata', object: preparation_type
