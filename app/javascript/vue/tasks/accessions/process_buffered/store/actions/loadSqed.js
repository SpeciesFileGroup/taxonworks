import { GetCollectingEvent, GetCollectionObject } from '../../request/resource'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }, id) => {
  GetCollectionObject(id).then(response => {
    commit(MutationNames.SetCollectionObject, response.body)
    if (state.collectionObject.collecting_event_id) {
      GetCollectingEvent(state.collectionObject.collecting_event_id).then(response => {
        state.collectingEvent = response.body
      })
    }
  })
}
