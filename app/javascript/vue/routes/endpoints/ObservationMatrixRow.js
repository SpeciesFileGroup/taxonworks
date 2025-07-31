import baseCRUD, { annotations } from './base'
import { ajaxCall } from '@/helpers'

const permitParams = {
  observation_matrix_row: Object
}

export const ObservationMatrixRow = {
  ...baseCRUD('observation_matrix_rows', permitParams),
  ...annotations('observation_matrix_rows'),

  sort: (ids) => ajaxCall('patch', '/observation_matrix_rows/sort', { ids })
}
