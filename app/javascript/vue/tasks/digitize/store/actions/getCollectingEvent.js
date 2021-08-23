import { MutationNames } from '../mutations/mutations'
import { CollectingEvent } from 'routes/endpoints'
import {
  COLLECTING_EVENT,
  IDENTIFIER_LOCAL_TRIP_CODE
} from 'constants/index.js'
import makeIdentifier from 'factory/CollectingEvent'

export default ({ commit }, id) =>
  CollectingEvent.find(id).then(({ body }) => {
    commit(MutationNames.SetCollectingEvent, body)
    commit(MutationNames.SetCollectingEventIdentifier, body.identifiers[0] || makeIdentifier(IDENTIFIER_LOCAL_TRIP_CODE, COLLECTING_EVENT))
  })
