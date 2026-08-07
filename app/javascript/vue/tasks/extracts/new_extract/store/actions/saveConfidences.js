import { Confidence } from '@/routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import { EXTRACT } from '@/constants'

export default ({ state, commit }) => {
  const objectId = state.extract.id
  const unsavedConfidences = state.confidences.filter((c) => c.isUnsaved)
  const promises = unsavedConfidences.map((confidence) => {
    const payload = {
      confidence: {
        confidence_object_id: objectId,
        confidence_object_type: EXTRACT,
        confidence_level_id: confidence.confidenceLevelId
      }
    }
    const request = confidence.id
      ? Confidence.update(confidence.id, payload)
      : Confidence.create(payload)

    request
      .then(({ body }) => {
        commit(MutationNames.AddConfidence, body)
      })
      .catch(() => {})

    return request
  })

  return Promise.all(promises)
}
