import { People } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import ActionNames from './actionNames'

export default ({ commit, dispatch }, personId) =>
  People.find(personId, { extend: ['roles'] }).then(({ body }) => {
    commit(MutationNames.SetSelectedPerson, body)
    commit(MutationNames.AddPersonToFoundList, body)
    dispatch(ActionNames.FindMatchPeople, {
      name: body.cached,
      levenshtein_cuttoff: 3
    })
  })
