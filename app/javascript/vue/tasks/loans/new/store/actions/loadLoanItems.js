import { MutationNames } from '../mutations/mutations'
import { LoanItem } from 'routes/endpoints'
import extend from '../../const/extend.js'
import getPagination from 'helpers/getPagination'

export default ({ commit }, { loanId, page = 1, per = 50 }) => {
  const payload = {
    loan_id: loanId,
    per,
    page,
    extend
  }

  commit(MutationNames.SetLoading, true)

  LoanItem.where(payload).then((response) => {
    commit(MutationNames.SetLoanItems, response.body)
    commit(MutationNames.SetLoading, false)
    commit(MutationNames.SetPagination, getPagination(response))
  })
}
