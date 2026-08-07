import { addToArray } from '@/helpers/arrays'

export default (state, relationship) => {
  addToArray(state.taxonRelationshipList, relationship)
}
