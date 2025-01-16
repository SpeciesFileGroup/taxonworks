json.extract! conveyance, :id, :sound_id, :conveyance_object_id, :conveyance_object_type, :project_id, :created_by_id, :updated_by_id, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object: conveyance
