import ActionNames from './actionNames'
import { MutationNames } from '../mutations/mutations'
import { CollectingEvent } from 'routes/endpoints'
import { RouteNames } from 'routes/routes'
import SetParam from 'helpers/setParam'
import extend from '../../const/extendRequest.js'

export default ({ state, dispatch, commit }, ceId) => {
  state.settings.isLoading = true

  CollectingEvent.find(ceId, { extend }).then(async response => {
    const collectingEvent = response.body

    if (collectingEvent.units === undefined) collectingEvent.units = 'm'

    collectingEvent.roles_attributes = collectingEvent.collector_roles || []
    commit(MutationNames.SetCollectingEvent, collectingEvent)
    await dispatch(ActionNames.LoadGeoreferences, ceId)
    await dispatch(ActionNames.LoadSoftValidations, collectingEvent.global_id)
    await dispatch(ActionNames.LoadCELabel, ceId)
    await dispatch(ActionNames.LoadIdentifier, ceId)
    commit(MutationNames.UpdateLastSave)

    SetParam(RouteNames.NewCollectingEvent, 'collecting_event_id', collectingEvent.id)
  }).finally(() => {
    state.settings.isLoading = false
  })
}
