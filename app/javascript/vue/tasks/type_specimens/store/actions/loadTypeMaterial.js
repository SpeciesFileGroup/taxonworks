import { ActionNames } from './actions'
import { MutationNames } from '../mutations/mutations'
import { Identifier } from 'routes/endpoints'
import makeIdentifier from '../../const/identifier'

export default ({ commit, dispatch }, type_material) => {
  Identifier.where({
    identifier_object_type: 'CollectionObject',
    identifier_object_id: type_material.collection_object.id,
    type: 'Identifier::Local::CatalogNumber'
  }).then(({ body }) => {
    commit(MutationNames.SetIdentifier, body.length
      ? body[0]
      : makeIdentifier()
    )
  })

  type_material.collection_object_attributes = type_material.collection_object
  commit(MutationNames.SetTypeMaterial, type_material)
  dispatch(ActionNames.LoadSoftValidations)
}
