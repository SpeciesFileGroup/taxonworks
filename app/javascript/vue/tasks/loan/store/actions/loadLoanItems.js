import { MutationNames } from '../mutations/mutations'
import { LoanItem } from 'routes/endpoints'

export default ({ commit }, id) => {
  commit(MutationNames.SetLoading, true)
  LoanItem.where({ loan_id: id }).then(response => {
    commit(MutationNames.SetLoanItems, response.body)
    commit(MutationNames.SetLoading, false)
  })
}
