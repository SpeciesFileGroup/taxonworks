import { Observation } from 'routes/endpoints'
import {
  setupContinuosPayload,
  setupFreeTextPayload,
  setupPresencePayload,
  setupQualitativePayload,
  setupSamplePayload
} from '../../helpers/setupPayload'
import ComponentNames from '../../helpers/ComponentNames'

const adaptPayload = {
  [ComponentNames.Continuous]: setupContinuosPayload,
  [ComponentNames.Sample]: setupSamplePayload,
  [ComponentNames.FreeText]: setupFreeTextPayload,
  [ComponentNames.Presence]: setupPresencePayload,
  [ComponentNames.Continuous]: setupContinuosPayload,
  [ComponentNames.Qualitative]: setupQualitativePayload
}

export default function ({
  columnId,
  descriptorType,
  observation
}) {
  const payload = []

  if (descriptorType === ComponentNames.Qualitative) {
    observation.characterStateId.forEach(id => {
      payload.push(getPayloadObservationFor(descriptorType, { characterStateId: id }))
    })
  } else {
    payload.push(getPayloadObservationFor(descriptorType, observation))
  }

  const requests = payload.map(payload =>
    Observation.codeRow({
      observation_matrix_column_id: columnId,
      observation: payload
    })
  )

  return Promise.allSettled(requests)
}

function getPayloadObservationFor (descriptorType, payload) {
  return adaptPayload[descriptorType](payload)
}
