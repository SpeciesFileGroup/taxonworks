import getSettings from './getSettings'

const GetterNames = {
  GetSettings: 'getSettings'
}

const GetterFunctions = {
  [GetterNames.GetSettings]: getSettings
}

export {
  GetterNames,
  GetterFunctions
}
