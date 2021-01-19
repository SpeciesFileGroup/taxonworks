import { makeInitialState } from '../store'
import { MutationNames } from '../mutations/mutations'
import { RouteNames } from 'routes/routes'
import SetParam from 'helpers/setParam'

export default ({ commit }) => {
  commit(MutationNames.SetStore, makeInitialState())
  SetParam(RouteNames.NewCollectingEvent, 'collecting_event_id')
  SetParam(RouteNames.NewCollectingEvent, 'collection_object_id')
}
