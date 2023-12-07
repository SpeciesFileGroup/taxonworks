import { Loan } from '@/routes/endpoints'

export default ({ commit, state }, loan) => {
  const payload = {
    ...loan,
    roles_attributes: [].concat(
      loan.loan_recipient_roles || [],
      loan.loan_supervisor_roles || []
    )
  }
  Loan.update(loan.id, { loan: payload, extend: ['roles'] }).then(() => {
    TW.workbench.alert.create('Loan was successfully updated.', 'notice')
  })
}
