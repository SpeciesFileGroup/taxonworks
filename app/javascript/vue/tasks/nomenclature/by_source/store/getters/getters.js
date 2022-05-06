import getCitationsByType from "./getCitationsByType"
import getOtuList from './getOtuList'

const GetterNames = {
  GetCitationsByType: 'getCitationsByType',
  GetOtuList: 'getOtuList'
}

const GetterFunctions = {
  [GetterNames.GetCitationsByType]: getCitationsByType,
  [GetterNames.GetOtuList]: getOtuList
}

export {
  GetterNames,
  GetterFunctions
}
