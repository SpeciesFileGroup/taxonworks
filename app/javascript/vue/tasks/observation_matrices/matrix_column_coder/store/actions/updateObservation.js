import ObservationTypes from '../../helpers/ObservationTypes'
import { MutationNames } from '../mutations/mutations'
import { Observation } from 'routes/endpoints'

export default function ({ state, commit }, { rowObjectId, rowObjectType, observationId }) {
  const observation = state.observations.find(o => o.id === observationId)

  commit(MutationNames.SetRowObjectSaving, {
    rowObjectId,
    rowObjectType,
    isSaving: true
  })

  return Observation.update(observation.id, { observation: makePayload(observation) })
    .then(_ => {
      commit(MutationNames.SetObservation, {
        ...observation,
        isUnsaved: false
      })
      commit(MutationNames.SetRowObjectSaving, {
        rowObjectId,
        rowObjectType,
        isSaving: false
      })

      commit(MutationNames.SetRowObjectUnsaved, {
        rowObjectId,
        rowObjectType,
        isUnsaved: false
      })

      commit(MutationNames.SetRowObjectSavedOnce, {
        rowObjectId,
        rowObjectType
      })
      return true
    }, _ => {
      commit(MutationNames.SetRowObjectSaving, {
        rowObjectId,
        rowObjectType,
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
