import ActionNames from './actionNames'
import createRowItem from './createRowItem'
import loadMatrix from './loadMatrix'

const ActionFunctions = {
  [ActionNames.CreateRowItem]: createRowItem,
  [ActionNames.LoadMatrix]: loadMatrix,
}

export { ActionNames, ActionFunctions }