import getLicense from './getLicense'

const GetterNames = {
  GetLicense: 'getLicense'
}

const GetterFunctions = {
  [GetterNames.GetLicense]: getLicense
}

export {
  GetterNames,
  GetterFunctions
}
