import { GetLabelsFromCE } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'
import { ActionNames } from '../actions/actions'

export default function ({ dispatch, commit }, id) {
  return new Promise((resolve, reject) => {
    GetLabelsFromCE(id).then(response => {
      if(response.body.length)
        commit(MutationNames.SetLabel, response.body[0])
      else 
        dispatch(ActionNames.NewLabel)
      resolve(response.body)
    }, error => {
      reject(error)
    })
  })
}