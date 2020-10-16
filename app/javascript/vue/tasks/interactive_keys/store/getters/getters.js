import getDescriptorsFilter from './getDescriptorsFilter'
import getObservationMatrix from './getObservationMatrix'
import getObservationMatrixDescriptors from './getObservationMatrixDescriptors'
import getSettings from './getSettings'
import getFilter from './getFilter'
import getParamsFilter from './getParamsFilter'

const GetterNames = {
  GetDescriptorsFilter: 'getDescriptorsFilter',
  GetObservationMatrix: 'getObservationMatrix',
  GetObservationMatrixDescriptors: 'getObservationMatrixDescriptors',
  GetSettings: 'getSettings',
  GetFilter: 'getFilter',
  GetParamsFilter: 'getParamsFilter'
}

const GetterFunctions = {
  [GetterNames.GetDescriptorsFilter]: getDescriptorsFilter,
  [GetterNames.GetObservationMatrix]: getObservationMatrix,
  [GetterNames.GetObservationMatrixDescriptors]: getObservationMatrixDescriptors,
  [GetterNames.GetSettings]: getSettings,
  [GetterNames.GetFilter]: getFilter,
  [GetterNames.GetParamsFilter]: getParamsFilter
}

export {
  GetterNames,
  GetterFunctions
}
