import { CreateCollectingEvent, UpdateCollectionObject, UpdateCollectingEvent } from '../../request/resource'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }) => {
  var promises = []
  const CEId = state.collectionObject.collecting_event_id
  state.settings.isSaving = true

  if (CEId) {
    promises.push(UpdateCollectingEvent(state.collectingEvent).then(response => {
      commit(MutationNames.SetCollectingEvent, state.collectingEvent)
    }))
  } else {
    promises.push(CreateCollectingEvent(state.collectingEvent).then(response => {
      state.collectionObject.collecting_event_id = response.id
    }))
  }

  Promise.all(promises).then(() => {
    UpdateCollectionObject(state.collectionObject).then(response => {
      commit(MutationNames.SetCollectionObject, response.body)
      state.settings.isSaving = false
      TW.workbench.alert.create('Sqed was successfully saved.', 'notice')
    })
  })
}
