import { CreateIdentifier, UpdateIdentifier } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }) => {
  let identifier = state.identifier
  if (identifier.identifier && identifier.namespace_id && state.settings.saveIdentifier) {
    identifier.identifier_object_id = state.type_material.collection_object.id
    
    if (state.identifier.id) {
      UpdateIdentifier(identifier).then(response => {
        commit(MutationNames.SetIdentifier, response.body)
        TW.workbench.alert.create('Identifier was successfully updated.', 'notice')
      })
    } else {
      CreateIdentifier(identifier).then(response => {
        commit(MutationNames.SetIdentifier, response.body)
        TW.workbench.alert.create('Identifier was successfully created.', 'notice')
      })
    }
  }
}
