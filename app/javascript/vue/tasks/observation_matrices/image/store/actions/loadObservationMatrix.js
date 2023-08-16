import AjaxCall from '@/helpers/ajaxCall'
import composeImage from '../../utils/composeImage'
import ActionNames from './actionNames'
import { MutationNames } from '../mutations/mutations'

const addImagesToDepictions = (rows, images) =>
  rows.map((observation) => ({
    ...observation,
    depictions: observation.depictions.map((obsDepictions) =>
      obsDepictions
        .filter(
          (depiction) => depiction.depiction_object_type === 'Observation'
        )
        .map((depiction) => ({
          ...depiction,
          image: composeImage(depiction.image_id, images[depiction.image_id])
        }))
    )
  }))

const parsePagination = (values) => ({
  paginationPage: Number(values.pagination_page),
  nextPage: Number(values.pagination_next_page),
  previousPage: Number(values.pagination_previous_page),
  perPage: Number(values.pagination_per_page),
  total: Number(values.pagination_total),
  totalPages: Number(values.pagination_total_pages)
})

export default ({ commit, dispatch, state }, params) => {
  state.isLoading = true

  AjaxCall(
    'get',
    `/tasks/observation_matrices/image_matrix/${params.observation_matrix_id}/key`,
    { params }
  )
    .then(({ body }) => {
      commit(MutationNames.SetPagination, parsePagination(body.pagination))
      commit(MutationNames.SetObservationMatrix, body.observation_matrix)
      commit(MutationNames.SetObservationColumns, body.list_of_descriptors)
      commit(
        MutationNames.SetObservationLanguages,
        body.descriptor_available_languages
      )
      commit(
        MutationNames.SetObservationRows,
        addImagesToDepictions(
          Object.values(body.depiction_matrix),
          body.image_hash
        )
      )
      dispatch(ActionNames.LoadOtuDepictions)
    })
    .finally((_) => {
      state.isLoading = false
    })
}
