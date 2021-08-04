import ActionNames from './actionNames'

import requestDescription from './requestDescription'
import requestMatrixRow from './requestMatrixRow'
import requestConfidenceLevels from './requestConfidenceLevels'
import requestObservations from './requestObservations'
import requestDescriptorNotes from './requestDescriptorNotes'
import requestDescriptorDepictions from './requestDescriptorDepictions'
import requestObservationNotes from './requestObservationNotes'
import requestObservationDepictions from './requestObservationDepictions'
import requestObservationConfidences from './requestObservationConfidences'
import requestObservationCitations from './requestObservationCitations'
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
  [ActionNames.RequestConfidenceLevels]: requestConfidenceLevels,
  [ActionNames.RequestObservations]: requestObservations,
  [ActionNames.RequestDescriptorNotes]: requestDescriptorNotes,
  [ActionNames.RequestDescriptorDepictions]: requestDescriptorDepictions,
  [ActionNames.RequestObservationNotes]: requestObservationNotes,
  [ActionNames.RequestObservationDepictions]: requestObservationDepictions,
  [ActionNames.RequestObservationConfidences]: requestObservationConfidences,
  [ActionNames.RequestObservationCitations]: requestObservationCitations,
  [ActionNames.RemoveObservation]: removeObservation,
  [ActionNames.RemoveObservationsRow]: removeObservationsRow,
  [ActionNames.UpdateObservation]: updateObservation,
  [ActionNames.CreateObservation]: createObservation,
  [ActionNames.CreateClone]: createClone,
  [ActionNames.SaveObservationsFor]: saveObservationsFor,
  [ActionNames.RequestUnits]: requestUnits
}

export { ActionNames, ActionFunctions }
