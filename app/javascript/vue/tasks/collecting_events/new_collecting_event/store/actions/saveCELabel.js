import { CreateLabel, UpdateLabel } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'
import { copyObjectByProperties } from 'helpers/objects'
import makeLabel from '../../const/makeLabel'

export default async ({ commit, state }) => {
  const newLabel = makeLabel()
  const label = state.ceLabel
  const saveLabel = label.id ? UpdateLabel : CreateLabel

  if (label.text.length && label.total) {
    label.label_object_id = state.collectingEvent.id
    saveLabel(copyObjectByProperties(label, newLabel)).then(response => {
      commit(MutationNames.SetCELabel, response.body)
    })
  }
}
