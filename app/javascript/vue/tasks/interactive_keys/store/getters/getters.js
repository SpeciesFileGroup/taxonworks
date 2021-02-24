import getDescriptorsFilter from './getDescriptorsFilter'
import getObservationMatrix from './getObservationMatrix'
import getObservationMatrixDescriptors from './getObservationMatrixDescriptors'
import getSettings from './getSettings'
import getFilter from './getFilter'
import getParamsFilter from './getParamsFilter'
import getRowFilter from './getRowFilter'

const GetterNames = {
  GetDescriptorsFilter: 'getDescriptorsFilter',
  GetObservationMatrix: 'getObservationMatrix',
  GetObservationMatrixDescriptors: 'getObservationMatrixDescriptors',
  GetSettings: 'getSettings',
  GetFilter: 'getFilter',
  GetParamsFilter: 'getParamsFilter',
  GetRowFilter: 'getRowFilter'
}

const GetterFunctions = {
  [GetterNames.GetDescriptorsFilter]: getDescriptorsFilter,
  [GetterNames.GetObservationMatrix]: getObservationMatrix,
  [GetterNames.GetObservationMatrixDescriptors]: getObservationMatrixDescriptors,
  [GetterNames.GetSettings]: getSettings,
  [GetterNames.GetFilter]: getFilter,
  [GetterNames.GetParamsFilter]: getParamsFilter,
  [GetterNames.GetRowFilter]: getRowFilter
}

export {
  GetterNames,
  GetterFunctions
}
