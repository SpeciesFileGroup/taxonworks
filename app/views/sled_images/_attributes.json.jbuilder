json.extract! sled_image, :id, :image_id, :metadata, :object_layout, :step_identifier_on, :created_at, :updated_at
json.partial! '/shared/data/all/metadata', object: sled_image

json.summary sled_image.summary
