import { addToArray } from "helpers/arrays"

export default ({ dispatch, commit, state }, mergePersonIndex) => {
  const selected = Object.assign({}, state.selectedPerson)
  const mergePerson = Object.assign({}, state.mergeList[mergePersonIndex])

  if (!mergePerson.id) return

  state.selectedPerson = mergePerson
  addToArray(state.foundPeople, mergePerson)

  state.mergeList[mergePersonIndex] = selected
  addToArray(state.matchPeople, selected)
}
