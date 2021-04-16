import { GetIdentifiers } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default ({ commit, state }) => {
  const { extract } = state
  GetIdentifiers(extract.id).then(({ body }) => {
    commit(MutationNames.SetIdentifiers, body)
  })
}
