import getSettings from './getSettings'
import getExtract from './getExtract'
import getSoftValidation from './getSoftValidation'

const GetterNames = {
  GetExtract: 'getExtract',
  GetSettings: 'getSettings',
  GetSoftValidation: 'getSoftValidation'
}

const GetterFunctions = {
  [GetterNames.GetExtract]: getExtract,
  [GetterNames.GetSettings]: getSettings,
  [GetterNames.GetSoftValidation]: getSoftValidation
}

export {
  GetterNames,
  GetterFunctions
}
