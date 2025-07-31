import { makeIdentifier } from '@/adapters'

export default (state, { objectType, item }) => {
  state.identifiers[objectType].push(makeIdentifier(item))
}
