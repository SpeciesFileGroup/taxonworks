json.extract! depiction, :id, :depiction_object, :image_id, :caption, :figure_label, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.object_tag depiction_tag(depiction)
json.url depiction_url(depiction, format: :json)

json.image do
  json.partial! '/images/attributes', image: depiction.image
end


