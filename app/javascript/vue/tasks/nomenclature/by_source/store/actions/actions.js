import ActionNames from './actionNames.js'
import loadCitations from './loadCitations'
import loadOtuByProxy from './loadOtuByProxy.js'

const ActionFunctions = {
  [ActionNames.LoadCitations]: loadCitations,
  [ActionNames.LoadOtuByProxy]: loadOtuByProxy
}

export {
  ActionFunctions,
  ActionNames
}
