import { CollectingEvent } from 'routes/endpoints'
import ActionNames from './actionNames'
import extend from '../../const/extendRequest.js'

export default ({ dispatch, state }) => {
  state.settings.isSaving = true

  CollectingEvent.clone(state.collectingEvent.id, { extend }).then(response => {
    dispatch(ActionNames.LoadCollectingEvent, response.body.id)
    TW.workbench.alert.create('Collecting event was successfully cloned.', 'notice')
  }).finally(() => {
    state.settings.isSaving = false
  })
}
