import { MutationNames } from '../mutations/mutations'
import { Loan } from 'routes/endpoints'
import ActionNames from './actionNames'

export default ({ commit, state, dispatch }, id) => {
  commit(MutationNames.SetLoading, true)
  return Loan.find(id).then(response => {
    commit(MutationNames.SetLoading, false)
    commit(MutationNames.SetLoan, response.body)
    dispatch(ActionNames.LoadLoanItems, id)
  })
}
