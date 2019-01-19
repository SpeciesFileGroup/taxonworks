import addCitation from './addCitation'
import addToOtuList from './addToOtuList'
import addTopicSelected from './addTopicSelected'
import addToSourceList from './addToSourceList'
import removeCitationSelected from './removeCitationSelected'
import removeOtuFormCitationList from './removeOtuFormCitationList'
import removeSourceFormCitationList from './removeSourceFormCitationList'
import removeTopicSelected from './removeTopicSelected'
import setCitationsList from './setCitationsList'
import setCurrentCitation from './setCurrentCitation'
import setOtuCitationsList from './setOtuCitationsList'
import setOtuSelected from './setOtuSelected'
import setSourceCitationsList from './setSourceCitationsList'
import setSourceSelected from './setSourceSelected'
import setTopicsList from './setTopicsList'
import setTopicsSelected from './setTopicsSelected'

const MutationNames = {
  AddCitation: 'addCitation',
  AddToOtuList: 'addToOtuList',
  AddTopicSelected: 'addTopicSelected',
  AddToSourceList: 'addToSourceList',
  RemoveCitationSelected: 'removeCitationSelected',
  RemoveOtuFormCitationList: 'removeOtuFormCitationList',
  RemoveSourceFormCitationList: 'removeSourceFormCitationList',
  RemoveTopicSelected: 'removeTopicSelected',
  SetCitationsList: 'setCitationsList',
  SetCurrentCitation: 'setCurrentCitation',
  SetOtuCitationsList: 'setOtuCitationsList',
  SetOtuSelected: 'setOtuSelected',
  SetSourceCitationsList: 'setSourceCitationsList',
  SetSourceSelected: 'setSourceSelected',
  SetTopicsList: 'setTopicsList',
  SetTopicsSelected: 'setTopicsSelected'
}

const MutationFunctions = {
  [MutationNames.AddCitation]: addCitation,
  [MutationNames.AddToOtuList]: addToOtuList,
  [MutationNames.AddTopicSelected]: addTopicSelected,
  [MutationNames.AddToSourceList]: addToSourceList,
  [MutationNames.RemoveCitationSelected]: removeCitationSelected,
  [MutationNames.RemoveOtuFormCitationList]: removeOtuFormCitationList,
  [MutationNames.RemoveSourceFormCitationList]: removeSourceFormCitationList,
  [MutationNames.RemoveTopicSelected]: removeTopicSelected,
  [MutationNames.SetCitationsList]: setCitationsList,
  [MutationNames.SetCurrentCitation]: setCurrentCitation,
  [MutationNames.SetOtuCitationsList]: setOtuCitationsList,
  [MutationNames.SetOtuSelected]: setOtuSelected,
  [MutationNames.SetSourceCitationsList]: setSourceCitationsList,
  [MutationNames.SetSourceSelected]: setSourceSelected,
  [MutationNames.SetTopicsList]: setTopicsList,
  [MutationNames.SetTopicsSelected]: setTopicsSelected
}

export {
  MutationNames,
  MutationFunctions
}
