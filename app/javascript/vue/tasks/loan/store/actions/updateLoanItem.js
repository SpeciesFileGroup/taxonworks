import { MutationNames } from '../mutations/mutations'
import { updateLoanItem } from '../../request/resources'

export default function ({ commit, state }, object) {
  commit(MutationNames.SetSaving, true)
  updateLoanItem({ loan_item: object }).then(response => {
    commit(MutationNames.AddLoanItem, response.body)
    commit(MutationNames.SetSaving, false)
  })
};
