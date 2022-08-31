import { IDENTIFIER_LOCAL_TRIP_CODE, COLLECTING_EVENT } from 'constants/index.js'
import { CollectingEvent } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import { ActionNames } from './actions'
import makeCollectingEvent from 'factory/CollectingEvent.js'
import makeIdentifier from 'factory/Identifier.js'

export default ({ dispatch, commit }, collectingEventId) => {
  CollectingEvent.clone(collectingEventId, { extend: ['roles'] }).then(({ body }) => {
    const clonedCE = Object.assign(makeCollectingEvent(), body)

    commit(MutationNames.SetCollectingEvent, clonedCE)
    commit(MutationNames.SetCollectingEventIdentifier, clonedCE?.identifiers[0] || makeIdentifier(IDENTIFIER_LOCAL_TRIP_CODE, COLLECTING_EVENT))
    dispatch(ActionNames.LoadGeoreferences, clonedCE.id)
    dispatch(ActionNames.SaveDigitalization)
  })
}
