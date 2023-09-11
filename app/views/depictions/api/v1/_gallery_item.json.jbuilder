json.extract! depiction, :id, :depiction_object_id, :depiction_object_type, :image_id,
:caption, :figure_label, :is_metadata_depiction,
:svg_view_box,
:created_at, :updated_at

json.label label_for_depiction(depiction)

json.depiction_object do
  json.label object_tag(depiction.depiction_object)
end

json.attribution do
  if depiction.image.attribution
    json.label label_for_attribution(depiction.image.attribution)
    json.id depiction.image.attribution.id
  end
end

json.figures do
  json.medium depiction_tag(depiction, size: :medium)
  json.thumb depiction_tag(depiction, size: :thumb)
end


json.original depiction.image.image_file.url(:original) # If timestamp becomes problem, timestamp: false
json.thumb depiction.image.image_file.url(:thumb) # If timestamp becomes problem, timestamp: false
json.medium depiction.image.image_file.url(:medium)

