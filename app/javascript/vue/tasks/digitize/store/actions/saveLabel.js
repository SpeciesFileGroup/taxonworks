import { MutationNames } from '../mutations/mutations'
import { UpdateLabel, CreateLabel } from '../../request/resources'
import ValidateLabel from '../../validations/label'

export default function ({ commit, state }) {
  return new Promise((resolve, reject) => {
    let label = state.label
    label.label_object_id = state.collection_event.id
    if(ValidateLabel(label)) {
      if(label.id) {
        UpdateLabel(label).then(response => {
          commit(MutationNames.SetLabel, response.body)
          return resolve(response.body)
        })
      }
      else {
        CreateLabel(label).then(response => {
          commit(MutationNames.SetLabel, response.body)
          return resolve(response.body)
        })
      }
    }
  })
}