import getObservationMatrix from './getObservationMatrix'
import getObservationMatrixDescriptors from './getObservationMatrixDescriptors'
import getSettings from './getSettings'

const GetterNames = {
  GetObservationMatrix: 'getObservationMatrix',
  GetObservationMatrixDescriptors: 'getObservationMatrixDescriptors',
  GetSettings: 'getSettings'
}

const GetterFunctions = {
  [GetterNames.GetObservationMatrix]: getObservationMatrix,
  [GetterNames.GetObservationMatrixDescriptors]: getObservationMatrixDescriptors,
  [GetterNames.GetSettings]: getSettings
}

export {
  GetterNames,
  GetterFunctions
}
