import { Otu, TaxonName, CollectionObject } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

const objectClass = {
  otu_id: Otu,
  collection_object_id: CollectionObject,
  taxon_name_id: TaxonName
}

function requestDepictions (item) {
  const [property, request] = item.base_class === 'Otu'
    ? ['id', Otu]
    : Object.entries(objectClass).find(([key, value]) => item[key])

  return request.depictions(item[property])
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
