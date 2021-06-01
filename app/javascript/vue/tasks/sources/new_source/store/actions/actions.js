import ActionNames from './actionNames'
import cloneSource from './cloneSource'
import convertToBibtex from './convertToBibtex'
import loadSource from './loadSource'
import resetSource from './resetSource'
import saveDocumentation from './saveDocumentation'
import saveSource from './saveSource'
import removeDocumentation from './removeDocumentation'

const ActionFunctions = {
  [ActionNames.CloneSource]: cloneSource,
  [ActionNames.ConvertToBibtex]: convertToBibtex,
  [ActionNames.LoadSource]: loadSource,
  [ActionNames.ResetSource]: resetSource,
  [ActionNames.SaveDocumentation]: saveDocumentation,
  [ActionNames.SaveSource]: saveSource,
  [ActionNames.RemoveDocumentation]: removeDocumentation
}

export {
  ActionNames,
  ActionFunctions
}
