import ActionNames from './actionNames.js'
import loadCitations from './loadCitations'
import loadOtuByProxy from './loadOtuByProxy.js'
import loadSource from './loadSource.js'
import updateCitation from './updateCitation'
import removeCitation from './removeCitation.js'

const ActionFunctions = {
  [ActionNames.LoadCitations]: loadCitations,
  [ActionNames.LoadOtuByProxy]: loadOtuByProxy,
  [ActionNames.LoadSource]: loadSource,
  [ActionNames.UpdateCitation]: updateCitation,
  [ActionNames.RemoveCitation]: removeCitation
}

export {
  ActionFunctions,
  ActionNames
}
