import { addToArray } from "helpers/arrays"

export default (state, relationship) => {
  if (relationship.id) {
    addToArray(state.originRelationships, relationship)
  } else {
    addToArray(state.originRelationships, relationship, 'uuid')
  }
}