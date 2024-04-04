import { COLLECTING_EVENT } from '@/constants/index.js'
import { Label } from '@/routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import makeLabel from '@/factory/Label.js'

export default async ({ commit, state }) => {
  const label = state.ceLabel

  if (label.id && !label.text.trim().length) {
    return Label.destroy(label.id).then((_) => {
      state.ceLabel = makeLabel(COLLECTING_EVENT)
    })
  }

  const payload = {
    label: {
      label_object_id: state.collectingEvent.id,
      label_object_type: COLLECTING_EVENT,
      total: label.total,
      text: label.text
    }
  }

  const request = label.id
    ? Label.update(label.id, payload)
    : Label.create(payload)

  request.then(({ body }) => {
    commit(MutationNames.SetCELabel, body)
  })

  return request
}
