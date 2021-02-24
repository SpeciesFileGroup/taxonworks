import { MutationNames } from '../mutations/mutations'
import { LoadSoftvalidation, GetIdentifiersFromCO } from '../../request/resources'

export default function ({ commit }, type_material) {
  GetIdentifiersFromCO(type_material.collection_object.id).then(response => {
    if (response.body.length) {
      commit(MutationNames.SetIdentifier, response.body[0])
    }
  })
  LoadSoftvalidation(type_material.global_id).then(response => {
    let validation = response.body.validations.soft_validations
    LoadSoftvalidation(type_material.collection_object.global_id).then(response => {
      commit(MutationNames.SetSoftValidation, validation.concat(response.body.validations.soft_validations))
    })
  })
  type_material.collection_object_attributes = type_material.collection_object
  commit(MutationNames.SetTypeMaterial, type_material)
};
