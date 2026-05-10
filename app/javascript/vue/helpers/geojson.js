export function convertToLatLongOrder(coordinate) {
  const [longitude, latitude] = coordinate

  return [latitude, longitude]
}

function convertCoordinatesToLatLongOrder(coordinates) {
  if (!Array.isArray(coordinates)) {
    throw new TypeError('GeoJSON coordinates must be an array')
  }

  if (typeof coordinates[0] === 'number') {
    return convertToLatLongOrder(coordinates)
  }

  return coordinates.map((coordinate) =>
    convertCoordinatesToLatLongOrder(coordinate)
  )
}

function serializeGeoJsonGeometry(geometry) {
  if (geometry.type === 'GeometryCollection') {
    return JSON.stringify(
      geometry.geometries.map((item) => ({
        type: item.type,
        coordinates: item.coordinates
      }))
    )
  }

  return convertCoordinatesToLatLongOrder(geometry.coordinates)
}

function truncateGeoJsonDisplay(value, maxLength = 100) {
  const text = Array.isArray(value) ? JSON.stringify(value) : String(value)

  return text.length > maxLength ? `${text.slice(0, maxLength)}...` : text
}

export function formatGeoJsonGeometryForDisplay(geometry, maxLength = 100) {
  return truncateGeoJsonDisplay(
    serializeGeoJsonGeometry(geometry),
    maxLength
  )
}
