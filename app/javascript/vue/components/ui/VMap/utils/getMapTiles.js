import { MAP_TILES } from '../constants'
import L from 'leaflet'

export function getMapTiles() {
  return Object.entries(MAP_TILES).reduce((acc, [key, value]) => {
    acc[key] = L.tileLayer(value.url, value.options)

    return acc
  }, {})
}
