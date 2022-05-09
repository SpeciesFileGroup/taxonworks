import ActionNames from './actionNames.js'
import loadCitations from './loadCitations'
import loadOtuByProxy from './loadOtuByProxy.js'
import loadSource from './loadSource.js'

const ActionFunctions = {
  [ActionNames.LoadCitations]: loadCitations,
  [ActionNames.LoadOtuByProxy]: loadOtuByProxy,
  [ActionNames.LoadSource]: loadSource
}

export {
  ActionFunctions,
  ActionNames
}
