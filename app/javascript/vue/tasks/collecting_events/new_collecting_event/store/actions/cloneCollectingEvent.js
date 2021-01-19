import { CloneCollectionEvent } from '../../request/resources'
import ActionNames from './actionNames'

export default ({ dispatch, state }) => {
  state.settings.isSaving = true

  CloneCollectionEvent(state.collectingEvent.id).then(response => {
    dispatch(ActionNames.LoadCollectingEvent, response.body.id)
    TW.workbench.alert.create('Collecting event was successfully cloned.', 'notice')
  }).finally(() => {
    state.settings.isSaving = false
  })
}
