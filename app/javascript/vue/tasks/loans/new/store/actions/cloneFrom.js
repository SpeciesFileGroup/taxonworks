import { Loan } from '@/routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import { ROLE_LOAN_RECIPIENT, ROLE_LOAN_SUPERVISOR } from '@/constants/index.js'

export default ({ commit }, loanId) => {
  Loan.find(loanId, { extend: ['roles'] }).then(({ body }) => {
    const { id, ...rest } = body

    const supervisors = rest.loan_supervisor_roles.map(({ id, ...item }) => ({
      ...item,
      person_id: item.person.id,
      type: ROLE_LOAN_SUPERVISOR
    }))
    const recipient = rest.loan_recipient_roles.map(({ id, ...item }) => ({
      ...item,
      person_id: item.person.id,
      type: ROLE_LOAN_RECIPIENT
    }))

    commit(MutationNames.SetLoan, {
      ...rest,
      loan_recipient_roles: recipient,
      loan_supervisor_roles: supervisors
    })
  })
}
