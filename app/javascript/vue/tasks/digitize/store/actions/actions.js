import ActionNames from './actionNames'
import getTaxon from './getTaxon'

const ActionFunctions = {
  [ActionNames.GetTaxon]: getTaxon
}

export { ActionNames, ActionFunctions }
