import { GetTypeMaterialCO } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }, id) {
  GetTypeMaterialCO(id).then(response => {
    commit(MutationNames.SetTypeMaterial, response)
  })
}