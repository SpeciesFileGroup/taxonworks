import getCitationsByType from "./getCitationsByType"
import getOtuList from './getOtuList.js'
import getSource from './getSource.js'

const GetterNames = {
  GetCitationsByType: 'getCitationsByType',
  GetOtuList: 'getOtuList',
  GetSource: 'getSource'
}

const GetterFunctions = {
  [GetterNames.GetCitationsByType]: getCitationsByType,
  [GetterNames.GetOtuList]: getOtuList,
  [GetterNames.GetSource]: getSource
}

export {
  GetterNames,
  GetterFunctions
}
