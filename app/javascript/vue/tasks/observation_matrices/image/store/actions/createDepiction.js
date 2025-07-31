import { MutationNames } from '../mutations/mutations'
import { Depiction } from '@/routes/endpoints'
import { OBSERVATION } from '@/constants/index'

export default async (
  { state, commit },
  { observationId, columnIndex, rowIndex, imageId }
) => {
  const depiction = {
    image_id: imageId,
    depiction_object_id: observationId,
    depiction_object_type: OBSERVATION
  }

  commit(MutationNames.SetIsSaving, true)

  Depiction.create({ depiction })
    .then(({ body }) => {
      commit(MutationNames.AddDepiction, {
        rowIndex,
        columnIndex,
        depiction: body
      })
    })
    .finally((_) => {
      state.depictionMoved = undefined
      state.observationMoved = undefined

      commit(MutationNames.SetIsSaving, false)
    })
}
