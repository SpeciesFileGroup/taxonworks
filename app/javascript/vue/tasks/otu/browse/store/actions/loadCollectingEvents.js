import { GetCollectingEvents, GetGeoreferences } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

import { chunkArray } from 'helpers/arrays'

const maxCEPerCall = 100

export default ({ state, commit }, otusId) => {
  return new Promise((resolve, reject) => {
    GetCollectingEvents(otusId).then(response => {
      const CEs = response.body
      const CEIds = chunkArray(CEs.map(ce => ce.id), maxCEPerCall)
      const promises = []

      commit(MutationNames.SetCollectingEvents, state.collectingEvents.concat(CEs))
      if (CEs.length) {
        CEIds.forEach(idGroup => {
          promises.push(GetGeoreferences(idGroup))
        })

        Promise.all(promises).then(responses => {
          const georeferences = [].concat(...responses).map(({ body }) => body)

          console.log(...georeferences)
          commit(MutationNames.SetGeoreferences, state.georeferences.concat(...georeferences))
          resolve(CEs)
        })
      } else {
        resolve(CEs)
      }
    }, error => {
      reject(error)
    })
  })
}
