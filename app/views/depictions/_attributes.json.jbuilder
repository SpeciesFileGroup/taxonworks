json.extract! depiction, :id, :depiction_object_id, :depiction_object_type, :image_id, :caption, :figure_label, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object: depiction 

json.image do
  json.partial! '/images/attributes', image: depiction.image
end

if depiction.sqed_depiction
  json.sqed_depiction do
    json.extract! depiction.sqed_depiction, :id, :boundary_color, :boundary_finder, :has_border, :layout, :metadata_map, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at
  end
end
