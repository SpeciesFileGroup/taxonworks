import { MutationNames } from '../mutations/mutations'
import { LoanItem } from 'routes/endpoints'
import extend from '../../const/extend.js'
import getPagination from 'helpers/getPagination'
import { useRandomUUID } from 'helpers/random'

export default ({ commit }, { loanId, page = 1, per = 50 }) => {
  const payload = {
    loan_id: loanId,
    per,
    page,
    extend
  }

  commit(MutationNames.SetLoading, true)

  LoanItem.where(payload).then((response) => {
    const loanItems = response.body.map((item) => ({
      ...item,
      uuid: useRandomUUID()
    }))

    commit(MutationNames.SetEditLoanItems, [])
    commit(MutationNames.SetLoanItems, loanItems)
    commit(MutationNames.SetLoading, false)
    commit(MutationNames.SetPagination, getPagination(response))
  })
}
