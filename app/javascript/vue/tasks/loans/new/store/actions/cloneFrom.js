import { Loan } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }, loanId) => {
  Loan.find(loanId).then(({ body }) => {
    const { id, ...rest } = body

    commit(MutationNames.SetLoan, rest)
  })
}
