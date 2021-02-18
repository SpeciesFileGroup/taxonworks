import { MutationNames } from '../mutations/mutations'
import { createBatchLoad } from '../../request/resources'

export default function ({ commit, state }, object) {
  commit(MutationNames.SetLoading, true)
  createBatchLoad(object).then(response => {
    if (Array.isArray(response.body)) {
      response.forEach(function (element) {
        commit(MutationNames.AddLoanItem, element)
      })
    }
    commit(MutationNames.SetLoading, false)
  })
};
