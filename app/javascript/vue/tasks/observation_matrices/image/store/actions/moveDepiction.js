import { MutationNames } from '../mutations/mutations'
import { Depiction } from 'routes/endpoints'
import { OBSERVATION } from 'constants/index'

export default async ({ state, commit }, { observationId, columnIndex, rowIndex }) => {
  const { depictionMoved } = state

  const depiction = {
    id: depictionMoved.id,
    depiction_object_id: observationId,
    depiction_object_type: OBSERVATION
  }

  commit(MutationNames.SetIsSaving, true)

  const { body } = await Depiction.update(depiction.id, { depiction })

  commit(MutationNames.AddDepiction, {
    rowIndex,
    columnIndex,
    depiction: body
  })

  state.depictionMoved = undefined
  state.observationMoved = undefined

  commit(MutationNames.SetIsSaving, false)

  console.log('Depiction moved')
}
