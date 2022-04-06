import { addToArray } from 'helpers/arrays'

export default (state, person) => {
  addToArray(state.foundPeople, person)
}
