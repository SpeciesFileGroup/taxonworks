import { EXTRACT } from '@/constants'
import { MutationNames } from '../mutations/mutations'
import { Confidence } from '@/routes/endpoints'

export default ({ commit }, extractId) => {
  Confidence.where({
    confidence_object_id: extractId,
    confidence_object_type: EXTRACT
  }).then(({ body }) => {
    body.forEach((confidence) => {
      commit(MutationNames.AddConfidence, confidence)
    })
  })
}
