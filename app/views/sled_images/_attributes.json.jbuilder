json.extract! sled_depiction, :id, :created_at, :updated_at
json.partial! '/shared/data/all/metadata', object: sled_depiction
