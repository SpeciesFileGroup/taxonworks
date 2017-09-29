import ActionNames from './actionNames';

import requestMatrixRow from './requestMatrixRow';
import requestConfidenceLevels from './requestConfidenceLevels';
import requestObservations from './requestObservations';
import requestDescriptorNotes from './requestDescriptorNotes';
import requestDescriptorDepictions from './requestDescriptorDepictions';
import requestObservationNotes from './requestObservationNotes';
import requestObservationDepictions from './requestObservationDepictions';
import requestObservationConfidences from './requestObservationConfidences';
import requestObservationCitations from './requestObservationCitations';
import removeObservation from './removeObservation';
import updateObservation from './updateObservation';
import createObservation from './createObservation';
import saveObservationsFor from './saveObservationsFor';

const ActionFunctions = {
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
    [ActionNames.UpdateObservation]: updateObservation,
    [ActionNames.CreateObservation]: createObservation,
    [ActionNames.SaveObservationsFor]: saveObservationsFor
};

export { ActionNames, ActionFunctions };