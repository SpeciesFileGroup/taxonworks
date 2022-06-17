import { People } from 'routes/endpoints'

export default ({ state }, person) => {
  const isAlreadyInList =
    state.matchPeople.find(p => p.id === person.id) ||
    state.selectedPerson.id === person.id

  if (!isAlreadyInList) {
    person.cached = person.label
    state.requestState.isLoading = true
    People.find(person.id, { extend: ['roles'] }).then(response => {
      state.matchPeople.push(response.body)
      state.mergeList.push(response.body)
    }).finally(_ => {
      state.requestState.isLoading = false
    })
  }
}
