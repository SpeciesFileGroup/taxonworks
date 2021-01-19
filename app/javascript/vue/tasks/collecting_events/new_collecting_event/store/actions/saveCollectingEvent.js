import { CreateCollectingEvent, UpdateCollectingEvent } from '../../request/resources'
import { ActionNames } from '../actions/actions'
import { MutationNames } from '../mutations/mutations'
import { RouteNames } from 'routes/routes'
import SetParam from 'helpers/setParam'

export default async ({ state, commit, dispatch }) => {
  const collectingEvent = state.collectingEvent
  const saveCE = collectingEvent.id ? UpdateCollectingEvent : CreateCollectingEvent

  if (collectingEvent.units === 'ft') {
    ['minimum_elevation', 'maximum_elevation', 'elevation_precision'].forEach(key => {
      const elevationValue = Number(collectingEvent[key])
      collectingEvent[key] = elevationValue > 0 ? elevationValue / 3.281 : undefined
    })
    collectingEvent.units = undefined
  }

  state.settings.isSaving = true

  saveCE(collectingEvent).then(async response => {
    TW.workbench.alert.create(`Collecting event was successfully ${collectingEvent.id ? 'updated' : 'created'}.`, 'notice')
    commit(MutationNames.SetCollectingEvent, Object.assign({}, collectingEvent, response.body))
    await dispatch(ActionNames.ProcessGeoreferenceQueue)
    await dispatch(ActionNames.SaveCELabel)
    await dispatch(ActionNames.SaveIdentifier)
    commit(MutationNames.UpdateLastSave)

    SetParam(RouteNames.NewCollectingEvent, 'collecting_event_id', response.body.id)
  }).finally(() => {
    state.settings.isSaving = false
  })
}
