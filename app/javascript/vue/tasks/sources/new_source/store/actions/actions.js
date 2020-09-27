import ActionNames from './actionNames'
import resetSource from './resetSource'
import loadSource from './loadSource'
import saveSource from './saveSource'
import cloneSource from './cloneSource'
import convertToBibtex from './convertToBibtex'

const ActionFunctions = {
  [ActionNames.ResetSource]: resetSource,
  [ActionNames.LoadSource]: loadSource,
  [ActionNames.SaveSource]: saveSource,
  [ActionNames.CloneSource]: cloneSource,
  [ActionNames.ConvertToBibtex]: convertToBibtex
}

export {
  ActionNames,
  ActionFunctions
}
