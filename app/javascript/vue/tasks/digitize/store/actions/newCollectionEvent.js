import { MutationNames } from '../mutations/mutations'
import newCollectionEvent from '../../const/collectingEvent'
import identifierCE from '../../const/identifierCE'

export default function ({ commit, state }) {
  commit(MutationNames.SetCollectionEventIdentifier, identifierCE())
  if(!state.settings.locked.collecting_event) {
    commit(MutationNames.SetCollectionEvent, newCollectionEvent())
  }
}