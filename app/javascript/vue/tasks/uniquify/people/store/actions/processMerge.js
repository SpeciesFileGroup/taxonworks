import { People } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }) => {
  let selectedPerson = state.selectedPerson
  let foundPeople = [...state.foundPeople]
  let matchPeople = [...state.matchPeople]

  function processMerge (mergeList) {
    const mergePerson = mergeList.pop()
    state.requestState.isMerging = true

    People.merge(selectedPerson.id, {
      person_to_destroy: mergePerson.id,
      extend: ['roles']
    }).then(({ body }) => {
      const personIndex = foundPeople.findIndex(person => person.id === selectedPerson.id)

      foundPeople = foundPeople.filter(people => mergePerson.id !== people.id)
      matchPeople = matchPeople.filter(people => mergePerson.id !== people.id)

      selectedPerson = body

      if (personIndex > -1) {
        foundPeople[personIndex] = selectedPerson
      }
    }).finally(() => {
      if (mergeList.length) {
        processMerge(mergeList)
      } else {
        People.find(selectedPerson.id, { extend: ['roles'] }).then(({ body }) => {
          state.selectedPerson = body
          state.foundPeople = foundPeople
          state.matchPeople = matchPeople
          state.requestState.isMerging = false
          commit(MutationNames.SetMergePeople, [])
        })
      }
    })
  }

  processMerge([...state.mergeList])
}
