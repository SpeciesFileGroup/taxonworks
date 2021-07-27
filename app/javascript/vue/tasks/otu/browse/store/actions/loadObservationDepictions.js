import AjaxCall from 'helpers/ajaxCall'
import { MutationNames } from '../mutations/mutations'
import composeImage from 'tasks/observation_matrices/image/utils/composeImage'

export default async ({ state, commit }, otus) => {
  const key = (await AjaxCall('get', '/tasks/observation_matrices/image_matrix/0/key', { params: { otu_filter: otus.map(otu => otu.id).join('|') } })).body
  const descriptors = key.list_of_descriptors
  const depictions = descriptors
    .map((item, index) => key.depiction_matrix
      .map(otuRow => otuRow.depictions[index]
        .filter(item => item.depiction_object_type === 'Observation')
        .map(depiction => ({
          ...depiction,
          image: composeImage(depiction.image_id, key.image_hash[depiction.image_id])
        }))))
    .flat(2)

  commit(MutationNames.SetObservationsDepictions, depictions)
}
