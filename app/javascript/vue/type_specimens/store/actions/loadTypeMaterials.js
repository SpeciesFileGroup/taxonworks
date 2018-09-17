import { MutationNames } from '../mutations/mutations'
import { GetTypeMaterial, GetTaxonName } from '../../request/resources'

export default function ({ commit, state }, id) {
  return new Promise((resolve, rejected) => {
    GetTypeMaterial(id).then(response => {
      commit(MutationNames.SetTypeMaterials, response)
      commit(MutationNames.SetLoading, false)
      return resolve(response)
    }, () => {
      commit(MutationNames.SetLoading, false)
      return rejected()
    })
  })
};
