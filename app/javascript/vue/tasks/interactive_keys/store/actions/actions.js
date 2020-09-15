import ActionNames from './actionNames'

import loadObservationMatrix from './loadObservationMatrix'
import loadObservationMatrixDescriptors from './loadObservationMatrixDescriptors'

const ActionFunctions = {
  [ActionNames.LoadObservationMatrix]: loadObservationMatrix,
  [ActionNames.LoadObservationMatrixDescriptors]: loadObservationMatrixDescriptors
}

export {
  ActionNames,
  ActionFunctions
}
