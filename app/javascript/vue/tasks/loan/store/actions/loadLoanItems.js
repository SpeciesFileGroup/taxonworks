import { MutationNames } from '../mutations/mutations'
import { getLoanItems } from '../../request/resources'

export default function ({ commit, state }, id) {
  commit(MutationNames.SetLoading, true)
  getLoanItems(id).then(response => {
    commit(MutationNames.SetLoanItems, response.body)
    commit(MutationNames.SetLoading, false)
  })
}
