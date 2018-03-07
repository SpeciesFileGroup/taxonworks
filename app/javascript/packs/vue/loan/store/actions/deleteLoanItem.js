import { MutationNames } from '../mutations/mutations'
import { destroyLoanItem } from '../../request/resources'

export default function ({ commit, state }, id) {
  destroyLoanItem(id).then(response => {
    commit(MutationNames.RemoveLoanItem, id)
  })
};
