import { MutationNames } from '../mutations/mutations'
import { createBatchLoad } from '../../request/resources'

export default function ({ commit }, object) {
  commit(MutationNames.SetLoading, true)
  createBatchLoad(object).then(response => {
    if (Array.isArray(response.body)) {
      response.body.forEach((element) => {
        commit(MutationNames.AddLoanItem, element)
      })
      TW.workbench.alert.create('Loan item(s) was successfully created.', 'notice')
    }
    commit(MutationNames.SetLoading, false)
  })
}
