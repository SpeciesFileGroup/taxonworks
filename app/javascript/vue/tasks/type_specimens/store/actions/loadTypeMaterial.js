import { MutationNames } from '../mutations/mutations'
import { LoadSoftvalidation } from '../../request/resources'

export default function ({ commit, state }, material) {
  LoadSoftvalidation(material.global_id).then(response => {
    let validation = response.validations.soft_validations
    LoadSoftvalidation(material.collection_object.global_id).then(response => {
      commit(MutationNames.SetSoftValidation, validation.concat(response.validations.soft_validations))
    })
  })
  commit(MutationNames.SetTypeMaterial, material)
};
