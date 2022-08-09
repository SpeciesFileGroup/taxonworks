import getObservationFromArgs from '../../helpers/getObservationFromArgs'
import ObservationTypes from '../../helpers/ObservationTypes'
import { MutationNames } from '../mutations/mutations'
import { Observation } from 'routes/endpoints'

export default function ({ commit, state }, args) {
  const observation = getObservationFromArgs(state, args)
  const {
    rowObjectId,
    rowObjectType
  } = args

  if (observation?.id) { return Promise.resolve() }

  commit(MutationNames.SetRowObjectSaving, {
    rowObjectId,
    rowObjectType,
    isSaving: true
  })

  const payload = makeBasePayload()

  if (observation.type === ObservationTypes.FreeText) { setupFreeTextPayload(payload) }

  if (observation.type === ObservationTypes.Qualitative) { setupQualitativePayload(payload) }

  if (observation.type === ObservationTypes.Presence) { setupPresencePayload(payload) }

  if (observation.type === ObservationTypes.Sample) { setupSamplePayload(payload) }

  if (observation.type === ObservationTypes.Continuous) { setupContinuosPayload(payload) }

  return Observation.create({ observation: payload })
    .then(({ body: responseData }) => {
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

      if (isValidResponseData(responseData)) {
        commit(MutationNames.SetObservationId, makeObservationIdArgs(responseData.id, responseData.global_id))
        commit(MutationNames.SetObservation, {
          ...observation,
          id: responseData.id,
          global_id: responseData.global_id,
          isUnsaved: false
        })
      }
      return true
    }, _ => {
      commit(MutationNames.SetRowObjectSaving, {
        rowObjectId,
        rowObjectType,
        isSaving: false
      })

      return false
    })

  function isValidResponseData (data) {
    return data && data.id
  }

  function makeObservationIdArgs (observationId, globalId) {
    return Object.assign({}, args, { observationId, global_id: globalId })
  }

  function setupFreeTextPayload (payload) {
    return Object.assign(payload, { description: observation.description })
  }

  function setupQualitativePayload (payload) {
    return Object.assign(payload, { character_state_id: args.characterStateId })
  }

  function setupPresencePayload (payload) {
    return Object.assign(payload, { presence: observation.isChecked })
  }

  function setupContinuosPayload (payload) {
    return Object.assign(payload, {
      continuous_value: observation.continuousValue,
      continuous_unit: observation.continuousUnit
    })
  }

  function setupSamplePayload (payload) {
    return Object.assign(payload, {
      sample_n: observation.n,
      sample_min: observation.min,
      sample_max: observation.max,
      sample_median: null,
      sample_mean: null,
      sample_units: observation.units,
      sample_standard_deviation: null,
      sample_standard_error: null
    })
  }

  function makeBasePayload () {
    return {
      descriptor_id: state.descriptor.id,
      observation_object_id: rowObjectId,
      observation_object_type: rowObjectType,
      global_id: undefined,
      type: observation.type,
      day_made: observation.day,
      month_made: observation.month,
      year_made: observation.year
    }
  }
}
