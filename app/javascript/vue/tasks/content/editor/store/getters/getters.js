import getCitationsList from './getCitationsList'
import getContentSelected from './getContentSelected'
import getDepictionsList from './getDepictionsList'
import getOtuSelected from './getOtuSelected'
import getTopicSelected from './getTopicSelected'
import panelCitations from './panelCitations'
import panelFigures from './panelFigures'
import getCitationsBySource from './getCitationsBySource'

const GetterNames = {
  GetCitationsBySource: 'getCitationsBySource',
  GetCitationsList: 'getCitationsList',
  GetContentSelected: 'getContentSelected',
  GetDepictionsList: 'getDepictionsList',
  GetOtuSelected: 'getOtuSelected',
  GetTopicSelected: 'getTopicSelected',
  PanelCitations: 'panelCitations',
  PanelFigures: 'panelFigures'
}

const GetterFunctions = {
  [GetterNames.GetCitationsList]: getCitationsList,
  [GetterNames.GetCitationsBySource]: getCitationsBySource,
  [GetterNames.GetContentSelected]: getContentSelected,
  [GetterNames.GetDepictionsList]: getDepictionsList,
  [GetterNames.GetOtuSelected]: getOtuSelected,
  [GetterNames.GetTopicSelected]: getTopicSelected,
  [GetterNames.PanelCitations]: panelCitations,
  [GetterNames.PanelFigures]: panelFigures
}

export {
  GetterNames,
  GetterFunctions
}
