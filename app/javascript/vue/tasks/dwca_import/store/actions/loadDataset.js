import { GetDataset } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'
import SetParam from 'helpers/setParam'
import { RouteNames } from 'routes/routes'

export default ({ state, commit }, id) => {
  return new Promise((resolve, reject) => {
    GetDataset(id).then(response => {
      SetParam(RouteNames.DwcImport, 'import_dataset_id', id)
      commit(MutationNames.SetDataset, response.body)
      resolve(response.body)
    }, (error) => {
      reject(error)
    })
  })
}
