import ActionNames from './actionNames'
import resetSource from './resetSource'
import loadSource from './loadSource'
import saveSource from './saveSource'

const ActionFunctions = {
  [ActionNames.ResetSource]: resetSource,
  [ActionNames.LoadSource]: loadSource,
  [ActionNames.SaveSource]: saveSource
}

export { 
  ActionNames, 
  ActionFunctions
}
