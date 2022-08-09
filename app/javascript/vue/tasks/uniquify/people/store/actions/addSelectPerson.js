import { People } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import ActionNames from './actionNames'

export default ({ commit, dispatch, state }, personId) => {
  state.requestState.isLoading = true
  People.find(personId, { extend: ['roles'] }).then(({ body }) => {
    commit(MutationNames.SetSelectedPerson, body)
    commit(MutationNames.AddPersonToFoundList, body)
    dispatch(ActionNames.FindMatchPeople, {
      name: body.cached,
      levenshtein_cuttoff: 3
    })
  }).finally(() => {
    state.requestState.isLoading = false
  })
}
