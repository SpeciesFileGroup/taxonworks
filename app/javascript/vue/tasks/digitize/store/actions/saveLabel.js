import { MutationNames } from '../mutations/mutations'
import { Label } from 'routes/endpoints'
import ValidateLabel from '../../validations/label'

export default ({ commit, state: { label, collecting_event } }) => 
  new Promise((resolve, reject) => {
    if (!ValidateLabel(label)) return

    label.label_object_id = collecting_event.id

    const saveLabel = label.id
      ? Label.update(label.id, { label })
      : Label.create({ label })

    saveLabel.then(response => {
      commit(MutationNames.SetLabel, response.body)
      return resolve(response.body)
    })
  })
