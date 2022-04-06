import { makeInitialState } from '../store'
import { MutationNames } from '../mutations/mutations'
import { RouteNames } from 'routes/routes'
import SetParam from 'helpers/setParam'
import incrementIdentifier from 'tasks/digitize/helpers/incrementIdentifier.js'

export default ({ state: { collectingEvent, tripCode, preferences }, commit }) => {
  const newStore = {
    ...makeInitialState(),
    preferences
  }

  if (collectingEvent.id && preferences.incrementIdentifier) {
    newStore.tripCode.identifier = incrementIdentifier(tripCode.identifier)
    newStore.tripCode.namespace_id = tripCode.namespace_id
  }

  commit(MutationNames.SetStore, newStore)
  SetParam(RouteNames.NewCollectingEvent, 'collecting_event_id')
  SetParam(RouteNames.NewCollectingEvent, 'collection_object_id')
}
