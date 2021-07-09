import { MutationNames } from '../mutations/mutations'
import { Loan } from 'routes/endpoints'

export default ({ commit }, loan) => {
  commit(MutationNames.SetSaving, true)
  Loan.create({ loan }).then(response => {
    TW.workbench.alert.create('Loan was successfully created.', 'notice')
    commit(MutationNames.SetLoan, response.body)
    commit(MutationNames.SetSaving, false)
    history.pushState(null, null, `/tasks/loans/edit_loan/${response.body.id}`)
  })
}
