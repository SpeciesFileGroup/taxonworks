import ActionNames from './actionNames.js'

import loadCollectionObject from './loadCollectionObject'
import loadIdentifiers from './loadIdentifiers'

const ActionFunctions = {
  [ActionNames.LoadCollectionObject]: loadCollectionObject,
  [ActionNames.LoadIdentifiers]: loadIdentifiers
}

export {
  ActionFunctions,
  ActionNames
}
