import setSelectedPerson from './setSelectedPerson'
import addPersonToFoundList from './addPersonToFoundList'

const MutationNames = {
  SetSelectedPerson: 'setSelectedPerson',
  AddPersonToFoundList: 'addPersonToFoundList'
}

const MutationFunctions = {
  [MutationNames.AddPersonToFoundList]: addPersonToFoundList,
  [MutationNames.SetSelectedPerson]: setSelectedPerson
}

export {
  MutationFunctions,
  MutationNames
}
