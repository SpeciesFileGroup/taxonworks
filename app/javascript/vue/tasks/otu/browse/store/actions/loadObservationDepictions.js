import AjaxCall from 'helpers/ajaxCall'
import { MutationNames } from '../mutations/mutations'
import { Depiction } from 'routes/endpoints'

const loadDepictions = async (depictions) => {
  const promises = depictions.map(depiction => Depiction.find(depiction.id))

  return Promise.all(promises).then(responses => responses.map(response => response.body))
}

export default async ({ state, commit }, otus) => {
  const key = (await AjaxCall('get', '/tasks/observation_matrices/image_matrix/0/key', { params: { otu_filter: otus.map(otu => otu.id).join('|') } })).body
  const descriptors = key.list_of_descriptors
  const depictions = descriptors
    .map((item, index) => key.depiction_matrix
      .map(otuRow => otuRow.depictions[index]
        .filter(item => item.depiction_object_type === 'Observation')))
    .flat(2)

  console.log(depictions)
  commit(MutationNames.SetObservationsDepictions, await loadDepictions(depictions))
}
