import { CollectingEvent } from 'routes/endpoints'
import { ActionNames } from '../actions/actions'
import { MutationNames } from '../mutations/mutations'
import { RouteNames } from 'routes/routes'
import SetParam from 'helpers/setParam'

export default async ({ state, commit, dispatch }) => {
  const collectingEvent = state.collectingEvent

  if (collectingEvent.units === 'ft') {
    ['minimum_elevation', 'maximum_elevation', 'elevation_precision'].forEach(key => {
      const elevationValue = Number(collectingEvent[key])
      collectingEvent[key] = elevationValue > 0 ? elevationValue / 3.281 : undefined
    })
    collectingEvent.units = 'm'
  }

  state.settings.isSaving = true

  return (collectingEvent.id
    ? CollectingEvent.update(collectingEvent.id, { collecting_event: collectingEvent })
    : CollectingEvent.create({ collecting_event: collectingEvent })
  ).then(async response => {
    TW.workbench.alert.create(`Collecting event was successfully ${collectingEvent.id ? 'updated' : 'created'}.`, 'notice')
    commit(MutationNames.SetCollectingEvent, Object.assign({}, collectingEvent, response.body, { roles_attributes: response.body.collector_roles || [] }))
    await dispatch(ActionNames.ProcessGeoreferenceQueue)
    await dispatch(ActionNames.SaveCELabel)
    await dispatch(ActionNames.SaveIdentifier)
    await dispatch(ActionNames.LoadSoftValidations)
    commit(MutationNames.UpdateLastSave)

    SetParam(RouteNames.NewCollectingEvent, 'collecting_event_id', response.body.id)
  }).finally(() => {
    state.settings.isSaving = false
  })
}
