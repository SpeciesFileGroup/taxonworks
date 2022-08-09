import { Otu, TaxonName, CollectionObject } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

const requestFunctions = {
  CollectionObject,
  Otu,
  TaxonName
}

function requestDepictions (item) {
  const type = item.observation_object_type || item.base_class

  return type in requestFunctions
    ? requestFunctions[type].depictions(item.observation_object_id)
    : Promise.resolve()
}

export default ({ state: { observationRows }, commit }) => {
  const promises = observationRows.map(item => requestDepictions(item.object))

  Promise.all(promises).then(responses => {
    commit(MutationNames.SetObservationRows,
      observationRows.map((row, index) => ({
        ...row,
        objectDepictions: responses[index].body
      })))
  })
}
