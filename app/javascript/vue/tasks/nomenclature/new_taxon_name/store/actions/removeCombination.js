import { Combination } from "routes/endpoints"
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }, id) => {
  Combination.destroy(id).then(({ body }) => {
    commit(MutationNames.RemoveCombination, id)
  })
}
