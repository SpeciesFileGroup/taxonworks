import { People } from '@/routes/endpoints'

export default ({ state }, person) => {
  if (state.selectedPerson.id === person.id) {
    return;
  }

  const matchedPerson = state.matchPeople.find((p) => p.id === person.id)

  if (matchedPerson) {
    const personInMergeList = state.mergeList.includes((p) => p.id === person.id)
    if (!personInMergeList) {
      state.mergeList.push(matchedPerson)
    }
  } else {
    person.cached = person.label
    state.requestState.isLoading = true
    People.find(person.id, { extend: ['roles', 'role_counts'] })
      .then((response) => {
        state.matchPeople.push(response.body)
        state.mergeList.push(response.body)
      })
      .finally((_) => {
        state.requestState.isLoading = false
      })
  }
}
