import { IDENTIFIER_LOCAL_TRIP_CODE } from 'constants/index.js'
import { Label } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import { copyObjectByProperties } from 'helpers/objects'
import makeLabel from 'factory/Label.js'

export default async ({ commit, state }) => {
  const newLabel = makeLabel(IDENTIFIER_LOCAL_TRIP_CODE, 'CollectingEvent')
  const label = state.ceLabel

  if (label.text.length && label.total) {
    const data = copyObjectByProperties(label, newLabel)
    data.label_object_id = state.collectingEvent.id

    return (label.id
      ? Label.update(label.id, { label: data })
      : Label.create({ label: data })
    ).then(response => {
      commit(MutationNames.SetCELabel, response.body)
    })
  }
}
