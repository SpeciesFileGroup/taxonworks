import { CreateGeoreference, UpdateGeoreference } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default async ({ state, commit }) => {
  const promises = []

  state.queueGeoreferences.forEach(georeference => {
    const saveGeoreference = georeference.id ? UpdateGeoreference : CreateGeoreference

    georeference.collecting_event_id = state.collectingEvent.id
    promises.push(saveGeoreference(georeference).then(response => {
      commit(MutationNames.AddGeoreference, response.body)
    }))
  })

  Promise.all(promises).then(() => {
    commit(MutationNames.SetQueueGeoreferences, [])
  })
}
