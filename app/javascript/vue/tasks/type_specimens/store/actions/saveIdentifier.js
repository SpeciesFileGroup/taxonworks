import { Identifier } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }) => {
  const identifier = state.identifier
  if (identifier.identifier && identifier.namespace_id && state.settings.saveIdentifier) {
    identifier.identifier_object_id = state.type_material.collection_object.id

    if (state.identifier.id) {
      Identifier.update(state.identifier.id, { identifier }).then(response => {
        commit(MutationNames.SetIdentifier, response.body)
        TW.workbench.alert.create('Identifier was successfully updated.', 'notice')
      })
    } else {
      Identifier.create({ identifier }).then(response => {
        commit(MutationNames.SetIdentifier, response.body)
        TW.workbench.alert.create('Identifier was successfully created.', 'notice')
      })
    }
  }
}
