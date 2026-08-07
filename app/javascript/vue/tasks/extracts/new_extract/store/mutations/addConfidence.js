import { addToArray } from '@/helpers'

function makeConfidence(item) {
  return {
    id: item.id,
    confidenceLevelId: item.confidence_level_id,
    label: item.object_tag || item.name,
    isUnsaved: item.isUnsaved
  }
}

export default (state, value) => {
  addToArray(state.confidences, makeConfidence(value), {
    property: 'confidenceLevelId'
  })
}
