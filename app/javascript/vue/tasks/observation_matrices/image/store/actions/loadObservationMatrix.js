import AjaxCall from 'helpers/ajaxCall'
import { MutationNames } from '../mutations/mutations'
import composeImage from '../../utils/composeImage'

const addImagesToDepictions = (rows, images) => rows
  .map(observation => ({
    ...observation,
    depictions: observation.depictions
      .map(obsDepictions => obsDepictions
        .filter(depiction => depiction.depiction_object_type === 'Observation')
        .map(depiction => ({
          ...depiction,
          image: composeImage(depiction.image_id, images[depiction.image_id])
        })))
  }))

export default ({ state, commit }, params) => {
  AjaxCall('get', `/tasks/observation_matrices/image_matrix/${params.observation_matrix_id}/key`, { params }).then(({ body }) => {
    commit(MutationNames.SetObservationMatrix, body.observation_matrix)
    commit(MutationNames.SetObservationColumns, body.list_of_descriptors)
    commit(MutationNames.SetObservationRows,
      addImagesToDepictions(
        Object.values(body.depiction_matrix),
        body.image_hash
      ))
  })
}
