import baseCRUD from './base'

const permitParams = {
  composition_item: {
    type: String,
    composition_id: Number,
    parent_id: Number,
    composition_item_object_id: Number,
    composition_item_object_type: String,
    text: String,
    x: Number,
    y: Number,
    z: Number,
    position: Number,
    width: Number,
    height: Number,
    zoom: Number,
    rotation_z: Number,
    svg_view_box: String,
    svg_clip: String,
    opacity: Number,
    is_visible: Boolean,
    total: Number,
    css_style: String
  }
}

export const CompositionItem = baseCRUD('composition_items', permitParams)
