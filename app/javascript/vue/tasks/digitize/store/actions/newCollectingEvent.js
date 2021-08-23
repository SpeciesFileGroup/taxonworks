import {
  COLLECTING_EVENT,
  IDENTIFIER_LOCAL_TRIP_CODE
} from 'constants/index.js'
import { MutationNames } from '../mutations/mutations'
import makeCollectingEvent from 'factory/CollectingEvent.js'
import makeIdentifier from 'factory/Identifier.js'

export default ({ commit, state }) => {
  commit(MutationNames.SetCollectingEventIdentifier, makeIdentifier(IDENTIFIER_LOCAL_TRIP_CODE, COLLECTING_EVENT))
  if (!state.settings.locked.collecting_event) {
    commit(MutationNames.SetCollectingEvent, makeCollectingEvent())
  }
}