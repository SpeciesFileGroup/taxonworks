import { CreateGeoreference } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default async ({ state, commit }) => {
  const promises = []

  state.queueGeoreferences.forEach(georeference => {
    georeference.collecting_event_id = state.collectingEvent.id
    promises.push(CreateGeoreference(georeference).then(response => {
      commit(MutationNames.AddGeoreference, response.body)
    }))
  })

  Promise.all(promises).then(() => {
    commit(MutationNames.SetQueueGeoreferences, [])
  })
}
