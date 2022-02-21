import { MutationNames } from '../mutations/mutations'
import { LoanItem } from 'routes/endpoints'
import extend from '../../const/extend.js'

export default ({ commit }, id) => {
  commit(MutationNames.SetLoading, true)
  LoanItem.where({ loan_id: id, extend }).then(response => {
    commit(MutationNames.SetLoanItems, response.body)
    commit(MutationNames.SetLoading, false)
  })
}
