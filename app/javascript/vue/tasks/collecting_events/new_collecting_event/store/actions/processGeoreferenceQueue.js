import { Georeference } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default async ({ state: { collectingEvent, queueGeoreferences }, commit }) =>
  new Promise((resolve, reject) => {
    if (!collectingEvent.id) return resolve()

    const requests = queueGeoreferences.map(item => {
      const georeference = {
        ...item,
        collecting_event_id: collectingEvent.id
      }

      const request = georeference.id
        ? Georeference.update(georeference.id, { georeference })
        : Georeference.create({ georeference })

      request.then(({ body }) => commit(MutationNames.AddGeoreference, body))

      return request
    })

    Promise.allSettled(requests).then(_ => {
      commit(MutationNames.SetQueueGeoreferences, [])
      resolve()
    }).catch(error => {
      reject(error)
    })
  })
