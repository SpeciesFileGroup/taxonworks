export default (shape, type = 'Georeference::Leaflet') => {
  console.log(shape)
  return {
    tmpId: Math.random().toString(36).substr(2, 5),
    geographic_item_attributes: { shape: JSON.stringify(shape) },
    error_radius: (shape.properties.hasOwnProperty('radius') ? shape.properties.radius : undefined),
    type: type
  }
}
