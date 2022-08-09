import { Label } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import makeLabel from 'factory/Label.js'

export default async ({ commit }, id) => {
  const label = (await Label.where({ label_object_id: id,label_object_type: 'CollectingEvent' })).body[0] || makeLabel('CollectingEvent')
  commit(MutationNames.SetCELabel, label)
}
