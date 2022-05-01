import { removeFromArray } from 'helpers/arrays'

export default (state, id) => {
  removeFromArray(state.matchPeople, { id })
}
