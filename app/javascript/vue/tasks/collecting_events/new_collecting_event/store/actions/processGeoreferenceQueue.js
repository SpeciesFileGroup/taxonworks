import { Georeference } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default async ({ state: { collectingEvent, queueGeoreferences }, commit }) => {
  if(!collectingEvent.id) return

  const promises = []

  queueGeoreferences.forEach(georeference => {
    georeference.collecting_event_id = collectingEvent.id
    promises.push(
      (georeference.id
        ? Georeference.update(georeference.id, { georeference: georeference })
        : Georeference.create({ georeference: georeference })
      ).then(response => {
        commit(MutationNames.AddGeoreference, response.body)
      })
    )
  })

  Promise.all(promises).then(() => {
    commit(MutationNames.SetQueueGeoreferences, [])
  })
}
