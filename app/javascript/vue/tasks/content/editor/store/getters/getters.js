import activeOtuPanel from './activeOtuPanel'
import activeRecentPanel from './activeRecentPanel'
import activeTopicPanel from './activeTopicPanel'
import getCitationsList from './getCitationsList'
import getContentSelected from './getContentSelected'
import getDepictionsList from './getDepictionsList'
import getOtuSelected from './getOtuSelected'
import getRecent from './getRecent'
import getTopicSelected from './getTopicSelected'
import panelCitations from './panelCitations'
import panelFigures from './panelFigures'
import getCitationsBySource from './getCitationsBySource'

const GetterNames = {
  ActiveOtuPanel: 'activeOtuPanel',
  ActiveRecentPanel: 'activeRecentPanel',
  ActiveTopicPanel: 'activeTopicPanel',
  GetCitationsBySource: 'getCitationsBySource',
  GetCitationsList: 'getCitationsList',
  GetContentSelected: 'getContentSelected',
  GetDepictionsList: 'getDepictionsList',
  GetOtuSelected: 'getOtuSelected',
  GetRecent: 'getRecent',
  GetTopicSelected: 'getTopicSelected',
  PanelCitations: 'panelCitations',
  PanelFigures: 'panelFigures'
}

const GetterFunctions = {
  [GetterNames.ActiveOtuPanel]: activeOtuPanel,
  [GetterNames.ActiveRecentPanel]: activeRecentPanel,
  [GetterNames.ActiveTopicPanel]: activeTopicPanel,
  [GetterNames.GetCitationsList]: getCitationsList,
  [GetterNames.GetCitationsBySource]: getCitationsBySource,
  [GetterNames.GetContentSelected]: getContentSelected,
  [GetterNames.GetDepictionsList]: getDepictionsList,
  [GetterNames.GetOtuSelected]: getOtuSelected,
  [GetterNames.GetRecent]: getRecent,
  [GetterNames.GetTopicSelected]: getTopicSelected,
  [GetterNames.PanelCitations]: panelCitations,
  [GetterNames.PanelFigures]: panelFigures
}

export {
  GetterNames,
  GetterFunctions
}
