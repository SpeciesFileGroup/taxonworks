import addCitationToList from './addCitationToList'
import addDepictionToList from './addDepictionToList'
import addToRecentContents from './addToRecentContents'
import addToRecentTopics from './addToRecentTopics'
import changeStateCitations from './changeStateCitations'
import changeStateFigures from './changeStateFigures'
import openOtuPanel from './openOtuPanel'
import removeCitation from './removeCitation'
import removeDepiction from './removeDepiction'
import setCitationList from './setCitationList'
import setContent from './setContent'
import setContentSelected from './setContentSelected'
import setDepictionsList from './setDepictionsList'
import setOtuSelected from './setOtuSelected'
import setRecentContents from './setRecentContents'
import setRecentOtus from './setRecentOtus'
import setRecentTopics from './setRecentTopics'
import setTopicSelected from './setTopicSelected'

const MutationNames = {
  AddCitationToList: 'addCitationToList',
  AddDepictionToList: 'addDepictionToList',
  AddToRecentContents: 'addToRecentContents',
  AddToRecentTopics: 'addToRecentTopics',
  ChangeStateCitations: 'changeStateCitations',
  ChangeStateFigures: 'changeStateFigures',
  OpenOtuPanel: 'openOtuPanel',
  RemoveCitation: 'removeCitation',
  RemoveDepiction: 'removeDepiction',
  SetCitationList: 'setCitationList',
  SetContent: 'setContent',
  SetContentSelected: 'setContentSelected',
  SetDepictionsList: 'setDepictionsList',
  SetOtuSelected: 'setOtuSelected',
  SetRecentContents: 'setRecentContents',
  SetRecentOtus: 'setRecentOtus',
  SetRecentTopics: 'setRecentTopics',
  SetTopicSelected: 'setTopicSelected'
}

const MutationFunctions = {
  [MutationNames.AddCitationToList]: addCitationToList,
  [MutationNames.AddDepictionToList]: addDepictionToList,
  [MutationNames.AddToRecentContents]: addToRecentContents,
  [MutationNames.AddToRecentTopics]: addToRecentTopics,
  [MutationNames.ChangeStateCitations]: changeStateCitations,
  [MutationNames.ChangeStateFigures]: changeStateFigures,
  [MutationNames.OpenOtuPanel]: openOtuPanel,
  [MutationNames.RemoveCitation]: removeCitation,
  [MutationNames.RemoveDepiction]: removeDepiction,
  [MutationNames.SetCitationList]: setCitationList,
  [MutationNames.SetContent]: setContent,
  [MutationNames.SetContentSelected]: setContentSelected,
  [MutationNames.SetDepictionsList]: setDepictionsList,
  [MutationNames.SetOtuSelected]: setOtuSelected,
  [MutationNames.SetRecentContents]: setRecentContents,
  [MutationNames.SetRecentOtus]: setRecentOtus,
  [MutationNames.SetRecentTopics]: setRecentTopics,
  [MutationNames.SetTopicSelected]: setTopicSelected
}

export {
  MutationNames,
  MutationFunctions
}
