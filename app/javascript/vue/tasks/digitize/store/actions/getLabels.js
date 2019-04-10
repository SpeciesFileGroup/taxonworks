import { GetLabelsFromCE } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'
import { ActionNames } from '../actions/actions'

export default function ({ dispatch, commit }, id) {
  return new Promise((resolve, reject) => {
    GetLabelsFromCE(id).then(response => {
      if(response.length)
        commit(MutationNames.SetLabel, response[0])
      else 
        dispatch(ActionNames.NewLabel)
      resolve(response)
    }, error => {
      reject(error)
    })
  })
}