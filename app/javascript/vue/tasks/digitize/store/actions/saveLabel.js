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
          TW.workbench.alert.create('Label was successfully updated.', 'notice')
          commit(MutationNames.SetLabel, response)
          return resolve(response)
        })
      }
      else {
        CreateLabel(label).then(response => {
          TW.workbench.alert.create('Label was successfully created.', 'notice')
          commit(MutationNames.SetLabel, response)
          return resolve(response)
        })
      }
    }
  })
}