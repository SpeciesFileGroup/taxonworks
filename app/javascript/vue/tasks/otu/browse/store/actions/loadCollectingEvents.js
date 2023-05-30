import { MutationNames } from '../mutations/mutations'
import { CollectingEvent, Georeference } from 'routes/endpoints'

import { chunkArray } from 'helpers/arrays'

const maxCEPerCall = 100

export default ({ state, commit }, otusId) =>
  new Promise((resolve, reject) => {
    CollectingEvent.all({ otu_id: otusId }).then(
      (response) => {
        const CEs = response.body

        commit(
          MutationNames.SetCollectingEvents,
          state.collectingEvents.concat(CEs)
        )
      },
      (error) => {
        reject(error)
      }
    )
  })
