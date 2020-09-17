import { MutationNames } from '../mutations/mutations'
import { DestroyTypeMaterial } from '../../request/resources'

export default function ({ commit, state }, typeMaterial) {
  return new Promise((resolve, reject) => {
    if(typeMaterial.hasOwnProperty('id')) {
      DestroyTypeMaterial(typeMaterial.id).then(response => {
        commit(MutationNames.RemoveTypeMaterial, typeMaterial.id)
        resolve(response.body)
      })
    }
  })
}