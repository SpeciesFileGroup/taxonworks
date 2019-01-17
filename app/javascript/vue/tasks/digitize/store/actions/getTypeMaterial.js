import { GetTypeMaterialCO } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }, id) {
  GetTypeMaterialCO(id).then(response => {
    response.roles_attributes = response.hasOwnProperty('roles') ? response.roles : []
    commit(MutationNames.SetTypeMaterial, response)
  })
}