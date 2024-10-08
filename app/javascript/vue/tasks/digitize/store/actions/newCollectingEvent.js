import {
  COLLECTING_EVENT,
  IDENTIFIER_LOCAL_FIELD_NUMBER
} from '@/constants/index.js'
import { MutationNames } from '../mutations/mutations'
import makeCollectingEvent from '@/factory/CollectingEvent.js'
import makeIdentifier from '@/factory/Identifier.js'

export default ({ commit, state }) => {
  commit(
    MutationNames.SetCollectingEventIdentifier,
    makeIdentifier(IDENTIFIER_LOCAL_FIELD_NUMBER, COLLECTING_EVENT)
  )
  if (!state.settings.locked.collecting_event) {
    commit(MutationNames.SetCollectingEvent, makeCollectingEvent())
    commit(MutationNames.SetGeoreferences, [])
    commit(MutationNames.SetCETotalUsed, 0)
  }
}
