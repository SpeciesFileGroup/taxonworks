import loadSqed from './loadSqed'
import loadSqedDepictions from './loadSqedDepictions'
import saveSqed from './saveSqed'

const ActionNames = {
  LoadSqued: 'loadSqued',
  LoadSqedDepictions: 'loadSqedDepictions',
  SaveSqed: 'saveSqed'
}
const ActionFunctions = {
  [ActionNames.LoadSqued]: loadSqed,
  [ActionNames.LoadSqedDepictions]: loadSqedDepictions,
  [ActionNames.SaveSqed]: saveSqed
}

export {
  ActionNames,
  ActionFunctions
}
