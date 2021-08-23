export default (shape, type = 'Georeference::Leaflet') => ({
  tmpId: Math.random().toString(36).substr(2, 5),
  geographic_item_attributes: { shape: JSON.stringify(shape) },
  error_radius: shape.properties?.radius,
  type: type
})
