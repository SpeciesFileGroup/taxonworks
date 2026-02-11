import { MAP_SHAPE_AGGREGATE } from '@/constants'

export function addAggregateDataToFeature(geometry) {
  return {
    geometry,
    properties: {
      base: [{ type: MAP_SHAPE_AGGREGATE, label: 'Aggregate map' }],
      shape: { type: MAP_SHAPE_AGGREGATE }
    },
    type: 'Feature'
  }
}
