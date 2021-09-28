import { ObservationMatrices } from 'routes/endpoints'

export default async ({ state }, id) => {
  ObservationMatrices.objectsByColumnId(id).then(({ body }) => {
    state.observationMatrix = body.observation_matrix
    state.otus = body.otus
    state.collection_objects = body.collection_objects
  })
}
