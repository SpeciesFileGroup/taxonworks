import { MutationNames } from '../mutations/mutations'
import newCollectionEvent from '../../const/collectingEvent'

export default function ({ commit, state }) {
  if(!state.settings.locked.collecting_event) {
    commit(MutationNames.SetCollectionEvent, newCollectionEvent())
  }
}