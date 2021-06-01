import { MutationNames } from '../mutations/mutations'
import { CollectingEvent } from 'routes/endpoints'

export default ({ commit, state }, id) =>
  CollectingEvent.find(id).then(response => {
    commit(MutationNames.SetCollectionEvent, response.body)
    if (state.collection_event?.identifiers?.length) {
      state.collectingEventIdentifier = state.collection_event.identifiers[0]
    }
  })
