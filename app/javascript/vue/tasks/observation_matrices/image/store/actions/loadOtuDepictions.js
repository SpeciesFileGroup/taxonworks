import { Depiction } from '@/routes/endpoints'
import { MutationNames } from '../mutations/mutations'

function requestDepictions(item) {
  const type = item.observation_object_type || item.base_class
  const id = item.observation_object_id || item.id

  return Depiction.where({
    depiction_object_id: id,
    depiction_object_type: type
  })
}

export default ({ state: { observationRows }, commit }) => {
  const promises = observationRows.map((item) => requestDepictions(item.object))

  Promise.all(promises).then((responses) => {
    commit(
      MutationNames.SetObservationRows,
      observationRows.map((row, index) => ({
        ...row,
        objectDepictions: responses[index].body
      }))
    )
  })
}
