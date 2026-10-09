json.extract! composition_item, :id, :type, :composition_id, :parent_id,
  :composition_item_object_id, :composition_item_object_type,
  :text, :x, :y, :z, :position, :width, :height, :zoom, :rotation_z,
  :svg_view_box, :svg_clip, :opacity, :is_visible, :total, :css_style,
  :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object: composition_item

if extend_response_with('composition_item_object') &&
    composition_item.composition_item_object
  json.composition_item_object do
    json.partial! '/shared/data/all/metadata',
      object: composition_item.composition_item_object, extensions: false
  end
end
