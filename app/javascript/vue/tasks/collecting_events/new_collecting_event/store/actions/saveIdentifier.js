import { UpdateIdentifier, CreateIdentifier } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'
import { copyObjectByProperties } from 'helpers/objects'
import makeIdentifier from '../../const/makeTripIdentifier'

export default async ({ state, commit }) => {
  const newIdentifier = makeIdentifier()
  const identifier = state.tripCode
  const saveIdentifier = identifier.id ? UpdateIdentifier : CreateIdentifier

  if (identifier.namespace_id && identifier.identifier) {
    identifier.identifier_object_id = state.collectingEvent.id
    saveIdentifier(copyObjectByProperties(identifier, newIdentifier)).then(response => {
      commit(MutationNames.SetIdentifier, response.body)
    })
  }
}
