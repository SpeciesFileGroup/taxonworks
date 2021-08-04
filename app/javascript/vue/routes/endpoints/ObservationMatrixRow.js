import baseCRUD, { annotations } from './base'

const permitParams = {
  observation_matrix_row: Object
}

export const ObservationMatrixRow = {
  ...baseCRUD('observation_matrix_rows', permitParams),
  ...annotations('observation_matrix_rows')
}
