import { SoftValidation } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit, state: { collectingEvent } }) => {
  SoftValidation.find(collectingEvent.global_id).then(({ body }) => {
    if (body.soft_validations.length) {
      commit(MutationNames.SetSoftValidations, { collectingEvent: { list: [body], title: 'Collecting event' } })
    }
  })
}
