import { MutationNames } from '../mutations/mutations'
import { LoadSoftvalidation } from '../../request/resources'

export default function ({ commit }, collection_object) {
  LoadSoftvalidation(collection_object.global_id).then(response => {
    let validation = response.validations.soft_validations
    LoadSoftvalidation(collection_object.collection_object.global_id).then(response => {
      commit(MutationNames.SetSoftValidation, validation.concat(response.validations.soft_validations))
    })
  })
  collection_object.collection_object_attributes = collection_object.collection_object
  commit(MutationNames.SetTypeMaterial, collection_object)
};
