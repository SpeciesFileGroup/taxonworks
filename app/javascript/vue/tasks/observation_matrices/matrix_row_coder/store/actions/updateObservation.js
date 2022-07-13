import ObservationTypes from '../helpers/ObservationTypes'
import { MutationNames } from '../mutations/mutations'

export default function ({state, commit}, { descriptorId, observationId }) {
  const observation = observationId
    ? state.observations.find(o => o.id === observationId)
    : state.observations.find(o => o.descriptorId === descriptorId)

  commit(MutationNames.SetDescriptorSaving, {
    descriptorId,
    isSaving: true
  })

  return state.request.updateObservation(observation.id, { observation: makePayload(observation) })
    .then(_ => {
      commit(MutationNames.SetObservation, {
        ...observation,
        isUnsaved: false
      })
      commit(MutationNames.SetDescriptorSaving, {
        descriptorId,
        isSaving: false
      })

      commit(MutationNames.SetDescriptorUnsaved, {
        descriptorId,
        isUnsaved: false
      })

      commit(MutationNames.SetDescriptorSavedOnce, descriptorId)
      return true
    }, _ => {
      commit(MutationNames.SetDescriptorSaving, {
        descriptorId,
        isSaving: false
      })
      return false
    })
}

function makePayload (observation) {
  const payload = {
    day_made: observation.day,
    month_made: observation.month,
    year_made: observation.year,
    time_made: observation.time
  }

  if (observation.type === ObservationTypes.Continuous) {
    Object.assign(payload, {
      continuous_value: observation.continuousValue,
      continuous_unit: observation.continuousUnit
    })
  } else if (observation.type === ObservationTypes.Sample) {
    Object.assign(payload, {
      sample_n: observation.n,
      sample_min: observation.min,
      sample_max: observation.max,
      sample_units: observation.units,
      sample_median: observation.median,
      sample_mean: observation.mean,
      sample_standard_deviation: observation.standardDeviation,
      sample_standard_error: observation.standardError
    })
  } else if (observation.type === ObservationTypes.Presence) {
    Object.assign(payload, { presence: observation.isChecked })
  } else if (observation.type === ObservationTypes.FreeText) {
    Object.assign(payload, { description: observation.description })
  }

  return payload
}
