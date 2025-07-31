import { MutationNames } from '../mutations/mutations'
import { Loan } from '@/routes/endpoints'

export default ({ commit }, loan) => {
  commit(MutationNames.SetSaving, true)
  const payload = {
    ...loan,
    roles_attributes: [].concat(
      loan.loan_recipient_roles || [],
      loan.loan_supervisor_roles || []
    )
  }

  Loan.create({ loan: payload, extend: ['roles'] })
    .then((response) => {
      TW.workbench.alert.create('Loan was successfully created.', 'notice')
      commit(MutationNames.SetLoan, response.body)
      commit(MutationNames.SetSaving, false)
      history.pushState(
        null,
        null,
        `/tasks/loans/edit_loan/${response.body.id}`
      )
    })
    .catch(() => {})
}
