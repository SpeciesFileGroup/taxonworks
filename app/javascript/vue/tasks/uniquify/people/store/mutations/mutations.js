import addPersonToFoundList from './addPersonToFoundList.js'
import setFoundPeople from './setFoundPeople.js'
import setMatchPeople from './setMatchPeople.js'
import setMergePeople from './setMergePeople.js'
import setSelectedPerson from './setSelectedPerson.js'
import setSettings from './setSettings'

const MutationNames = {
  AddPersonToFoundList: 'addPersonToFoundList',
  SetFoundPeople: 'setFoundPeople',
  SetMatchPeople: 'setMatchPeople',
  SetMergePeople: 'setMergePeople',
  SetSelectedPerson: 'setSelectedPerson',
  SetSettings: 'setSettings'
}

const MutationFunctions = {
  [MutationNames.AddPersonToFoundList]: addPersonToFoundList,
  [MutationNames.SetFoundPeople]: setFoundPeople,
  [MutationNames.SetMatchPeople]: setMatchPeople,
  [MutationNames.SetMergePeople]: setMergePeople,
  [MutationNames.SetSelectedPerson]: setSelectedPerson,
  [MutationNames.SetSettings]: setSettings
}

export {
  MutationFunctions,
  MutationNames
}
