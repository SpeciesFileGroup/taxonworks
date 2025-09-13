import { ObservationMatrix } from '@/routes/endpoints'

export default ({ state }) => {
  const payload = {
    observation_matrix: {
      id: state.matrix.id,
      name: state.matrix.name,
      otu_id: state.matrix.otu_id,
      is_public: state.matrix.is_public
    }
  }

  const request = state.matrix.id
    ? ObservationMatrix.update(state.matrix.id, payload)
    : ObservationMatrix.create(payload)

  request
    .then(({ body }) => {
      TW.workbench.alert.create('Matrix was successfully saved.', 'notice')
      state.matrix = body
    })
    .catch(() => {})

  return request
}
