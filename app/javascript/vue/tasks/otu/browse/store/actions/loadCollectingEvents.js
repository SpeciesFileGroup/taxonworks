import { MutationNames } from '../mutations/mutations'
import { CollectingEvent, Georeference } from 'routes/endpoints'

import { chunkArray } from 'helpers/arrays'

const maxCEPerCall = 100

export default ({ state, commit }, otusId) =>
  new Promise((resolve, reject) => {
    CollectingEvent.where({ otu_id: otusId }).then(response => {
      const CEs = response.body
      const CEIds = chunkArray(CEs.map(ce => ce.id), maxCEPerCall)
      const promises = []

      commit(MutationNames.SetCollectingEvents, state.collectingEvents.concat(CEs))
      if (CEs.length) {
        CEIds.forEach(idGroup => {
          promises.push(Georeference.where({ collecting_event_ids: idGroup }))
        })

        Promise.all(promises).then(responses => {
          const georeferences = [].concat(...responses).map(({ body }) => body)

          commit(MutationNames.SetGeoreferences, state.georeferences.concat(...georeferences))
          resolve(CEs)
        })
      } else {
        resolve(CEs)
      }
    }, error => {
      reject(error)
    }).finally(() => {
      state.loadState.distribution = false
    })
  })
