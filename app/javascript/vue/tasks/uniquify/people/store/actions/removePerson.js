import { removeFromArray } from '@/helpers'

export default ({ state }, item) => {
  removeFromArray(state.mergeList, item)
  removeFromArray(state.matchPeople, item)
  removeFromArray(state.foundPeople, item)

  if (state.selectedPerson?.id === item.id) {
    state.selectedPerson = {}
  }
}
