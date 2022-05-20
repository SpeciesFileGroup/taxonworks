import { sortArray } from "helpers/arrays"
import { MutationNames } from "../mutations/mutations"

export default ({ state, commit }, payload) => {
  const {
    type,
    ascending,
    property
  } = payload

  const orderList =  sortArray(state.citations[type], property, ascending)

  commit(MutationNames.SetCitationList, { 
    list: orderList, 
    type
  })
}
