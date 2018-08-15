import { GetTaxon } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }, id) {
  commit(MutationNames.SetTypeMaterialProtonymId, id)
  GetTaxon(id).then(response => {
    commit(MutationNames.SetTypeMaterialTaxon, response)
  })
}