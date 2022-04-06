import { People } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }, personId) =>
  People.find(personId, { extend: ['roles'] }).then(({ body }) => {
    commit(MutationNames.SetSelectedPerson, body)
    commit(MutationNames.AddPersonToFoundList, body)
  })
