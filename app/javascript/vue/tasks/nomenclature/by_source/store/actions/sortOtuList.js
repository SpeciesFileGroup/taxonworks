import { sortArray } from "helpers/arrays"
import { MutationNames } from "../mutations/mutations"

export default ({ state, commit }, payload) => {
  const {
    ascending,
    property
  } = payload

  const orderList =  sortArray(state.otuList, property, ascending)

  commit(MutationNames.SetOtuList, orderList)
}
