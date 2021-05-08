import baseCRUD from './base'

const controller = 'observation_matrix_columns'
const permitParams = {
  observation_matrix_column: Object
}

export const ObservationMatrixColumn = {
  ...baseCRUD(controller, permitParams)
}
