import { Georeference } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }, id) => {
  Georeference.where({ collecting_event_id: id }).then(({ body }) => {
    commit(MutationNames.SetGeoreferences, body)
  })
}
