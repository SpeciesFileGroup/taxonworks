import ActionNames from './actionNames.js'

import addSelectPerson from './addSelectPerson.js'
import findMatchPeople from './findMatchPeople.js'
import findPeople from './findPeople.js'
import processMerge from './processMerge.js'
import resetStore from './resetStore.js'

const ActionFunctions = {
  [ActionNames.AddSelectPerson]: addSelectPerson,
  [ActionNames.FindMatchPeople]: findMatchPeople,
  [ActionNames.FindPeople]: findPeople,
  [ActionNames.ProcessMerge]: processMerge,
  [ActionNames.ResetStore]: resetStore
}

export {
  ActionFunctions,
  ActionNames
}
