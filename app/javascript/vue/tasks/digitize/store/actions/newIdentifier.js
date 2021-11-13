import {
  COLLECTION_OBJECT,
  CONTAINER,
  IDENTIFIER_LOCAL_CATALOG_NUMBER
} from 'constants/index.js'
import { MutationNames } from '../mutations/mutations'
import makeIdentifier from 'factory/Identifier.js'
import IncrementIdentifier from '../../helpers/incrementIdentifier'

export default ({ commit, state }) => {
  const newIdentifier = makeIdentifier(IDENTIFIER_LOCAL_CATALOG_NUMBER, COLLECTION_OBJECT)
  const locked = state.settings.locked.identifier
  const identifier = state.identifier.identifier

  newIdentifier.identifier_object_type = state.container
    ? CONTAINER
    : COLLECTION_OBJECT

  if (locked) {
    newIdentifier.namespace_id = state.identifier.namespace_id
  }
  if (state.settings.increment && !state.container) {
    newIdentifier.identifier = IncrementIdentifier(identifier)
  }

  commit(MutationNames.SetIdentifier, newIdentifier)
}
