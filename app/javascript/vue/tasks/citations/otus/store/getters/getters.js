import getCitationSelected from './getCitationSelected'
import getCitationsList from './getCitationsList'
import getOtuCitationsList from './getOtuCitationsList'
import getOtuSelected from './getOtuSelected'
import getSetTopics from './getSetTopics'
import getSourceCitationsList from './getSourceCitationsList'
import getSourceSelected from './getSourceSelected'
import getTopicsList from './getTopicsList'
import objectsSelected from './objectsSelected'

const GetterNames = {
  GetCitationSelected: 'getCitationSelected',
  GetCitationsList: 'getCitationsList',
  GetOtuCitationsList: 'getOtuCitationsList',
  GetOtuSelected: 'getOtuSelected',
  GetSetTopics: 'getSetTopics',
  GetSourceCitationsList: 'getSourceCitationsList',
  GetSourceSelected: 'getSourceSelected',
  GetTopicsList: 'getTopicsList',
  ObjectsSelected: 'objectsSelected'
}

const GetterFunctions = {
  [GetterNames.GetCitationSelected]: getCitationSelected,
  [GetterNames.GetCitationsList]: getCitationsList,
  [GetterNames.GetOtuCitationsList]: getOtuCitationsList,
  [GetterNames.GetOtuSelected]: getOtuSelected,
  [GetterNames.GetSetTopics]: getSetTopics,
  [GetterNames.GetSourceCitationsList]: getSourceCitationsList,
  [GetterNames.GetSourceSelected]: getSourceSelected,
  [GetterNames.GetTopicsList]: getTopicsList,
  [GetterNames.ObjectsSelected]: objectsSelected
}

export {
  GetterNames,
  GetterFunctions
}
