import { GetDataset } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }, id) => {
  GetDataset(id).then(response => {
    commit(MutationNames.SetImport, response.body)
  })
}
