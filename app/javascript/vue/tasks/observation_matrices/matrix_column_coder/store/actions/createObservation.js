import getObservationFromArgs from '../../helpers/getObservationFromArgs'
import ObservationTypes from '../../helpers/ObservationTypes'
import { MutationNames } from '../mutations/mutations'
import { Observation } from 'routes/endpoints'
import {
  setupContinuosPayload,
  setupFreeTextPayload,
  setupPresencePayload,
  setupQualitativePayload,
  setupSamplePayload
} from '../../helpers/setupPayload'

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

  if (observation.type === ObservationTypes.FreeText) { Object.assign(payload, setupFreeTextPayload(observation)) }

  if (observation.type === ObservationTypes.Qualitative) { Object.assign(payload, setupQualitativePayload(args)) }

  if (observation.type === ObservationTypes.Presence) { Object.assign(payload, setupPresencePayload(observation)) }

  if (observation.type === ObservationTypes.Sample) { Object.assign(payload, setupSamplePayload(observation)) }

  if (observation.type === ObservationTypes.Continuous) { Object.assign(payload, setupContinuosPayload(observation)) }

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
