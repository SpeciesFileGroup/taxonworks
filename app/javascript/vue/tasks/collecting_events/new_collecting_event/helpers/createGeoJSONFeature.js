import ParseDMS from 'helpers/parseDMS'

export default (longitude, latitude) => {
  return {
    type: 'Feature',
    properties: {},
    geometry: {
      type: 'Point',
      coordinates: [ParseDMS(longitude), ParseDMS(latitude)]
    }
  }
}
