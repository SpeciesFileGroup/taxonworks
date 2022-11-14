import { MutationNames } from '../mutations/mutations'
import { Observation, Depiction } from 'routes/endpoints'
import { OBSERVATION } from 'constants/index'

export default async ({ state, commit }, { observationId, columnIndex, rowIndex }) => {
  const {
    depictionMoved,
    observationMoved
  } = state

  const depiction = {
    id: depictionMoved.id,
    depiction_object_id: observationId,
    depiction_object_type: OBSERVATION
  }

  const observation = {
    id: observationMoved.id,
    depictions_attributes: [depiction]
  }

  commit(MutationNames.SetIsSaving, true)

  const { body } = observation.id
    ? await Observation.update(observation.id, { observation })
    : await Depiction.update(depiction.id, { depiction })

  const payload = body.base_class === OBSERVATION
    ? {
        ...depictionMoved.value,
        ...depiction
      }
    : body

  commit(MutationNames.AddDepiction, {
    rowIndex,
    columnIndex,
    depiction: payload
  })

  state.depictionMoved = undefined
  state.observationMoved = undefined
  commit(MutationNames.SetIsSaving, false)
}
