import { GetSoftValidation } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default ({ commit, state: { collectingEvent } }) => {
  GetSoftValidation(collectingEvent.global_id).then(response => {
    commit(MutationNames.SetSoftValidations, { collectingEvent: { list: [response.body], title: 'Collecting event' }})
  })
}
