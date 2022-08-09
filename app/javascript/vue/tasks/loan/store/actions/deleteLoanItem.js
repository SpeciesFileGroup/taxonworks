import { MutationNames } from '../mutations/mutations'
import { LoanItem } from 'routes/endpoints'

export default ({ commit }, id) => {
  LoanItem.destroy(id).then(() => {
    commit(MutationNames.RemoveLoanItem, id)
  })
}
