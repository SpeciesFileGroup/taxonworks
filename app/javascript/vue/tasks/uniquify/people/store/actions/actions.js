import ActionNames from './actionNames.js'

import addMatchPerson from './addMatchPerson.js'
import addSelectPerson from './addSelectPerson.js'
import findMatchPeople from './findMatchPeople.js'
import findPeople from './findPeople.js'
import flipPeople from './flipPeople.js'
import processMerge from './processMerge.js'
import resetStore from './resetStore.js'

const ActionFunctions = {
  [ActionNames.AddMatchPerson]: addMatchPerson,
  [ActionNames.AddSelectPerson]: addSelectPerson,
  [ActionNames.FindMatchPeople]: findMatchPeople,
  [ActionNames.FindPeople]: findPeople,
  [ActionNames.FlipPeople]: flipPeople,
  [ActionNames.ProcessMerge]: processMerge,
  [ActionNames.ResetStore]: resetStore
}

export {
  ActionFunctions,
  ActionNames
}
