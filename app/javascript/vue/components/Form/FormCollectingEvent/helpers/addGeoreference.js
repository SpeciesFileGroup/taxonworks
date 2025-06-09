import { randomUUID } from '@/helpers'

export default (shape, type = 'Georeference::Leaflet') => ({
  uuid: randomUUID(),
  geographic_item_attributes: { shape: JSON.stringify(shape) },
  error_radius: shape.properties?.radius,
  type: type,
  isUnsaved: true
})
