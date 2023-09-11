import { removeFromArray } from '@/helpers/arrays'

export default function (state, relationship) {
  removeFromArray(state.taxonRelationshipList, relationship)
}
