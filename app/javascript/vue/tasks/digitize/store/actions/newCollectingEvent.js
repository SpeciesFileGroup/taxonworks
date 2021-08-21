import { MutationNames } from '../mutations/mutations'
import newCollectingEvent from '../../const/collectingEvent'
import identifierCE from '../../const/identifierCE'

export default function ({ commit, state }) {
  commit(MutationNames.SetCollectingEventIdentifier, identifierCE())
  if(!state.settings.locked.collecting_event) {
    commit(MutationNames.SetCollectingEvent, newCollectingEvent())
  }
}