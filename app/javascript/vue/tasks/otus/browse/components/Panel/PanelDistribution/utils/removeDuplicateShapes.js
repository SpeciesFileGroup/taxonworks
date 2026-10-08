export function removeDuplicateShapes(data) {
  const features = []
  const shapeTypes = []

  data.forEach((feature) => {
    const shapeId = feature.properties.shape.id
    const shapeType = feature.properties.shape.type

    if (!shapeTypes.includes(feature.properties.base.type)) {
      shapeTypes.push(feature.properties.base.type)
    }

    const index = features.findIndex(
      (item) =>
        item.properties.shape.id === shapeId &&
        item.properties.shape.type === shapeType
    )

    if (index > -1) {
      const currentFeature = features[index]

      currentFeature.properties.base.push(feature.properties.base)
      currentFeature.properties.target.push(feature.properties.target)
    } else {
      const item = structuredClone(feature)

      item.properties.type = item.properties.shape.type
      item.properties.base = [item.properties.base]
      item.properties.target = [item.properties.target]

      features.push(item)
    }
  })

  shapeTypes.sort()

  return {
    shapeTypes,
    features
  }
}
