import { MutationNames } from '../mutations/mutations'
import { Georeference } from 'routes/endpoints'

export default ({ commit }, ceId) => {
  Georeference.where({ collecting_event_id: ceId }).then(response => {
    commit(MutationNames.SetGeoreferences, response.body)
  })
}
