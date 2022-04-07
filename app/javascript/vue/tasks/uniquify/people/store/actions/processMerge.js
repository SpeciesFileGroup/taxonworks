import { People } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }) => {
  function processMerge (mergeList) {
    const mergePerson = mergeList.pop()
    state.requestState.isMerging = true

    People.merge(state.selectedPerson.id, {
      person_to_destroy: mergePerson.id,
      extend: ['roles']
    }).then(({ body }) => {
      const personIndex = state.foundPeople.findIndex(person => person.id === state.selectedPerson.id)

      state.foundPeople = state.foundPeople.filter(people => mergePerson.id !== people.id)
      state.matchPeople = state.matchPeople.filter(people => mergePerson.id !== people.id)

      state.selectedPerson = body

      if (personIndex > -1) {
        state.foundPeople[personIndex] = state.selectedPerson
      }
    }).finally(() => {
      if (mergeList.length) {
        processMerge(mergeList)
      } else {
        People.find(state.selectedPerson.id, { extend: ['roles'] }).then(({ body }) => {
          state.selectedPerson = body
          state.requestState.isMerging = false
          commit(MutationNames.SetMergePeople, [])
        })
      }
    })
  }

  processMerge([...state.mergeList])
}
