import { MutationNames } from '../mutations/mutations'
import { CreateExtract, UpdateExtract } from '../../request/resources'

export default ({ state, commit }) => {
  const { extract } = state
  const saveExtract = extract.id ? UpdateExtract : CreateExtract

  console.log(extract)

  saveExtract(extract).then(({ body }) => {
    commit(MutationNames.SetExtract, body)
  })
}
