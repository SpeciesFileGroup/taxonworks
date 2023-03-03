import { MutationNames } from '../mutations/mutations'
import { LoanItem } from 'routes/endpoints'
import extend from '../../const/extend.js'

export default ({ commit }, object) => {
  commit(MutationNames.SetSaving, true)
  LoanItem.update(object.id, { loan_item: object, extend }).then(response => {
    commit(MutationNames.AddLoanItem, response.body)
    commit(MutationNames.SetSaving, false)
  })
};
