import dataChangedSinceLastSave from './dataChangedSinceLastSave.js'
import loadKey from './loadKey.js'

const ActionNames = {
  DataChangedSinceLastSave: 'dataChangedSinceLastSave',
  LoadKey: 'loadKey'
}

const ActionFunctions = {
  [ActionNames.DataChangedSinceLastSave]: dataChangedSinceLastSave,
  [ActionNames.LoadKey]: loadKey
}

export {
  ActionNames,
  ActionFunctions
}