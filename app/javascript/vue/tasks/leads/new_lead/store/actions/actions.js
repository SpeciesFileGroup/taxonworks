import loadKey from './loadKey.js'

const ActionNames = {
  LoadKey: 'loadKey'
}

const ActionFunctions = {
  [ActionNames.LoadKey]: loadKey
}

export {
  ActionNames,
  ActionFunctions
}