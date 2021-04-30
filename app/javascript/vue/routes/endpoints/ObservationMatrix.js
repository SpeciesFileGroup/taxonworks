import baseCRUD from './base'

const permitParams = {
  observation_matrix: {
    name: String
  }
}

export const ObservationMatrix = {
  ...baseCRUD('observation_matrices', permitParams)
}
