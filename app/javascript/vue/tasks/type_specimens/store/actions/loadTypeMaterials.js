import { MutationNames } from '../mutations/mutations'
import { GetTypeMaterial } from '../../request/resources'

export default function ({ commit, state }, id) {
  return new Promise((resolve, rejected) => {
    GetTypeMaterial(id).then(response => {
      commit(MutationNames.SetTypeMaterials, response.body)
      commit(MutationNames.SetLoading, false)
      return resolve(response.body)
    }, () => {
      commit(MutationNames.SetLoading, false)
      return rejected()
    })
  })
};
