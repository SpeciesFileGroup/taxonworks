import ActionNames from './actionNames'

import requestDescription from './requestDescription'
import requestMatrixRow from './requestMatrixRow'
import requestObservations from './requestObservations'
import requestUnits from './requestUnits'
import removeObservation from './removeObservation'
import updateObservation from './updateObservation'
import createObservation from './createObservation'
import createClone from './createClone'
import saveObservationsFor from './saveObservationsFor'
import removeObservationsRow from './removeObservationsRow'

const ActionFunctions = {
  [ActionNames.RequestDescription]: requestDescription,
  [ActionNames.RequestMatrixRow]: requestMatrixRow,
  [ActionNames.RequestObservations]: requestObservations,
  [ActionNames.RemoveObservation]: removeObservation,
  [ActionNames.RemoveObservationsRow]: removeObservationsRow,
  [ActionNames.UpdateObservation]: updateObservation,
  [ActionNames.CreateObservation]: createObservation,
  [ActionNames.CreateClone]: createClone,
  [ActionNames.SaveObservationsFor]: saveObservationsFor,
  [ActionNames.RequestUnits]: requestUnits
}

export { ActionNames, ActionFunctions }
