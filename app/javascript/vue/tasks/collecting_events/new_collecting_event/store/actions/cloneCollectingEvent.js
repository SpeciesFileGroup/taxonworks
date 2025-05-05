import { CollectingEvent } from '@/routes/endpoints'
import ActionNames from './actionNames'

export default ({ dispatch, state }, params) => {
  state.settings.isSaving = true

  CollectingEvent.clone(state.collectingEvent.id, { ...params })
    .then(({ body }) => {
      dispatch(ActionNames.LoadCollectingEvent, body.id)
      TW.workbench.alert.create(
        'Collecting event was successfully cloned.',
        'notice'
      )
    })
    .finally(() => {
      state.settings.isSaving = false
    })
}
