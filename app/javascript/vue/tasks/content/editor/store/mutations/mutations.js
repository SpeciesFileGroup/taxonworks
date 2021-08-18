import addCitationToList from './addCitationToList'
import addDepictionToList from './addDepictionToList'
import changeStateCitations from './changeStateCitations'
import changeStateFigures from './changeStateFigures'
import removeCitation from './removeCitation'
import removeDepiction from './removeDepiction'
import setCitationList from './setCitationList'
import setContent from './setContent'
import setContentSelected from './setContentSelected'
import setDepictionsList from './setDepictionsList'
import setOtuSelected from './setOtuSelected'
import setTopicSelected from './setTopicSelected'

const MutationNames = {
  AddCitationToList: 'addCitationToList',
  AddDepictionToList: 'addDepictionToList',
  ChangeStateCitations: 'changeStateCitations',
  ChangeStateFigures: 'changeStateFigures',
  RemoveCitation: 'removeCitation',
  RemoveDepiction: 'removeDepiction',
  SetCitationList: 'setCitationList',
  SetContent: 'setContent',
  SetContentSelected: 'setContentSelected',
  SetDepictionsList: 'setDepictionsList',
  SetOtuSelected: 'setOtuSelected',
  SetTopicSelected: 'setTopicSelected'
}

const MutationFunctions = {
  [MutationNames.AddCitationToList]: addCitationToList,
  [MutationNames.AddDepictionToList]: addDepictionToList,
  [MutationNames.ChangeStateCitations]: changeStateCitations,
  [MutationNames.ChangeStateFigures]: changeStateFigures,
  [MutationNames.RemoveCitation]: removeCitation,
  [MutationNames.RemoveDepiction]: removeDepiction,
  [MutationNames.SetCitationList]: setCitationList,
  [MutationNames.SetContent]: setContent,
  [MutationNames.SetContentSelected]: setContentSelected,
  [MutationNames.SetDepictionsList]: setDepictionsList,
  [MutationNames.SetOtuSelected]: setOtuSelected,
  [MutationNames.SetTopicSelected]: setTopicSelected
}

export {
  MutationNames,
  MutationFunctions
}
