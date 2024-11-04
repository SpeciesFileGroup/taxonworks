import baseCRUD from './base'
import { ajaxCall } from '@/helpers'

const controller = 'observation_matrix_columns'
const permitParams = {
  observation_matrix_column: Object
}

export const ObservationMatrixColumn = {
  ...baseCRUD(controller, permitParams),

  sort: (ids) => ajaxCall('patch', `/${controller}/sort`, { ids })
}
