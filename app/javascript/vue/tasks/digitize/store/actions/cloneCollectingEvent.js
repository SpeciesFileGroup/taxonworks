import {
  IDENTIFIER_LOCAL_TRIP_CODE,
  COLLECTING_EVENT
} from '@/constants/index.js'
import { CollectingEvent } from '@/routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import { ActionNames } from './actions'
import makeCollectingEvent from '@/factory/CollectingEvent.js'
import makeIdentifier from '@/factory/Identifier.js'

export default ({ state, dispatch, commit }, params) => {
  const ceId = state.collecting_event.id

  CollectingEvent.clone(ceId, { ...params }).then(({ body }) => {
    const clonedCE = Object.assign(makeCollectingEvent(), body)

    commit(MutationNames.SetCollectingEvent, clonedCE)
    commit(
      MutationNames.SetCollectingEventIdentifier,
      clonedCE?.identifiers[0] ||
        makeIdentifier(IDENTIFIER_LOCAL_TRIP_CODE, COLLECTING_EVENT)
    )
    commit(MutationNames.SetGeoreferences, [])
    dispatch(ActionNames.LoadGeoreferences, clonedCE.id)
    dispatch(ActionNames.SaveDigitalization)
  })
}
