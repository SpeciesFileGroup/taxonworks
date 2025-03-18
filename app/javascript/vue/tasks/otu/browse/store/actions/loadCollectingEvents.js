import { MutationNames } from '../mutations/mutations'
import { CollectingEvent } from '@/routes/endpoints'

export default ({ state, commit }, otusId) =>
  new Promise((resolve, reject) => {
    CollectingEvent.all({ otu_id: otusId }).then(
      (response) => {
        const CEs = response.body

        commit(
          MutationNames.SetCollectingEvents,
          state.collectingEvents.concat(CEs)
        )
        state.loadState.collectingEvents = false
      },
      (error) => {
        reject(error)
      }
    )
  })
