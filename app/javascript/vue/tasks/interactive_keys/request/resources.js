import ajaxCall from 'helpers/ajaxCall'

const GetInteractiveKey = (id, params) => ajaxCall('get', `/tasks/observation_matrices/interactive_key/${id}/key`, { params: params })

// def key_params
// params.permit(
//   :observation_matrix_id,
//   :language_id,
//   :row_filter,
//   :sorting,
//   :eliminate_unknown,
//   :error_tolerance,
//   :identified_to_rank,
//   :selected_descriptors,
//   keyword_ids: [] # arrays must be at the end
// ).to_h.symbolize_keys.merge(project_id: sessions_current_project_id)
// end

export {
  GetInteractiveKey
}
