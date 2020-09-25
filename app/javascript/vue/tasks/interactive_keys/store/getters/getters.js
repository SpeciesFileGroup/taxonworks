import getDescriptorsFilter from './getDescriptorsFilter'
import getObservationMatrix from './getObservationMatrix'
import getObservationMatrixDescriptors from './getObservationMatrixDescriptors'
import getSettings from './getSettings'
import getFilter from './getFilter'

const GetterNames = {
  GetDescriptorsFilter: 'getDescriptorsFilter',
  GetObservationMatrix: 'getObservationMatrix',
  GetObservationMatrixDescriptors: 'getObservationMatrixDescriptors',
  GetSettings: 'getSettings',
  GetFilter: 'getFilter'
}

const GetterFunctions = {
  [GetterNames.GetDescriptorsFilter]: getDescriptorsFilter,
  [GetterNames.GetObservationMatrix]: getObservationMatrix,
  [GetterNames.GetObservationMatrixDescriptors]: getObservationMatrixDescriptors,
  [GetterNames.GetSettings]: getSettings,
  [GetterNames.GetFilter]: getFilter
}

export {
  GetterNames,
  GetterFunctions
}
