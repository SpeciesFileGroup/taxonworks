import ActionNames from './actionNames'
import addSelectPerson from './addSelectPerson'

const ActionFunctions = {
  [ActionNames.AddSelectPerson]: addSelectPerson
}

export {
  ActionFunctions,
  ActionNames
}
