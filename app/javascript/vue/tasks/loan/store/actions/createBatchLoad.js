import { MutationNames } from '../mutations/mutations'
import { createBatchLoad } from '../../request/resources'

export default function ({ commit }, object) {
  commit(MutationNames.SetLoading, true)
  createBatchLoad(object).then(response => {
    if (Array.isArray(response.body)) {
      response.body.forEach((element) => {
        commit(MutationNames.AddLoanItem, element)
      })
    }
    commit(MutationNames.SetLoading, false)
  })
}
