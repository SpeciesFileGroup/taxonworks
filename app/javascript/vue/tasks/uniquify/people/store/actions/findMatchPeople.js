import { People } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }, params) => {
  state.requestState.isLoading = true
  state.mergeList = []

  People.where({ ...params, extend: ['roles'] }).then(response => {
    commit(MutationNames.SetMatchPeople, response.body.filter(p => state.selectedPerson.id !== p.id))
    state.URLRequest = response.request.responseURL
  }).finally(_ => {
    state.requestState.isLoading = false
  })
}
