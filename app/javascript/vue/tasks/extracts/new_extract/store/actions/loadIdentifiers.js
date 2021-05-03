import { MutationNames } from '../mutations/mutations'
import { Extract } from 'routes/endpoints'

export default ({ commit, state: { extract } }) => {
  return Extract.identifiers(extract.id).then(({ body }) => {
    commit(MutationNames.SetIdentifiers, body)
  })
}
