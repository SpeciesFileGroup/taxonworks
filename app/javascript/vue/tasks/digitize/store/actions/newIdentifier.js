import { MutationNames } from '../mutations/mutations'
import NewIdentifier from '../../const/identifier'
import IncrementIdentifier from '../../helpers/incrementIdentifier'

export default function ({ commit, state }) {
  let newIdentifier = NewIdentifier()
  let locked = state.settings.locked.identifier
  let identifier = state.identifier.identifier

  newIdentifier.identifier_object_type = state.container ? 'Container' : 'CollectionObject'

  if(locked) {
    newIdentifier.namespace_id = state.identifier.namespace_id
  }
  if(state.settings.increment && !state.container) {
    newIdentifier.identifier = IncrementIdentifier(identifier)
  }

  commit(MutationNames.SetIdentifier, newIdentifier)  
}