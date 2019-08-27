import loadSqed from './loadSqed'
import loadSqedDepictions from './loadSqedDepictions'

const ActionNames = {
  LoadSqued: 'loadSqued',
  LoadSqedDepictions: 'loadSqedDepictions'
}
const ActionFunctions = {
  [ActionNames.LoadSqued]: loadSqed,
  [ActionNames.LoadSqedDepictions]: loadSqedDepictions
}

export {
  ActionNames,
  ActionFunctions
}
