import getDescriptorsFilter from './getDescriptorsFilter'
import getObservationMatrix from './getObservationMatrix'
import getObservationMatrixDescriptors from './getObservationMatrixDescriptors'
import getSettings from './getSettings'

const GetterNames = {
  GetDescriptorsFilter: 'getDescriptorsFilter',
  GetObservationMatrix: 'getObservationMatrix',
  GetObservationMatrixDescriptors: 'getObservationMatrixDescriptors',
  GetSettings: 'getSettings'
}

const GetterFunctions = {
  [GetterNames.GetDescriptorsFilter]: getDescriptorsFilter,
  [GetterNames.GetObservationMatrix]: getObservationMatrix,
  [GetterNames.GetObservationMatrixDescriptors]: getObservationMatrixDescriptors,
  [GetterNames.GetSettings]: getSettings
}

export {
  GetterNames,
  GetterFunctions
}
