import ActionNames from './actionNames'
import createRowItem from './createRowItem'

const ActionFunctions = {
  [ActionNames.CreateRowItem]: createRowItem,
}

export { ActionNames, ActionFunctions }