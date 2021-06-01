import { MutationNames } from '../mutations/mutations'
import { Identifier, SoftValidation } from 'routes/endpoints'

export default function ({ commit }, type_material) {
  Identifier.where({
    identifier_object_type: 'CollectionObject',
    identifier_object_id: type_material.collection_object.id,
    type: 'Identifier::Local::CatalogNumber'
  }).then(response => {
    if (response.body.length) {
      commit(MutationNames.SetIdentifier, response.body[0])
    }
  })
  SoftValidation.find(type_material.global_id).then(response => {
    const validation = response.body.soft_validations
    SoftValidation.find(type_material.collection_object.global_id).then(response => {
      commit(MutationNames.SetSoftValidation, validation.concat(response.body.soft_validations))
    })
  })
  type_material.collection_object_attributes = type_material.collection_object
  commit(MutationNames.SetTypeMaterial, type_material)
};
