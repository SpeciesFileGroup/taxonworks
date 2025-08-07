export default (layer) => {
  const layerJson = layer.toGeoJSON()

  if (typeof layer.getRadius === 'function') {
    layerJson.properties.radius = layer.getRadius()
  }

  return layerJson
}
