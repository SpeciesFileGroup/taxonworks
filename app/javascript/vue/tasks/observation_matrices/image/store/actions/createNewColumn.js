import { Descriptor, ObservationMatrixColumnItem } from 'routes/endpoints'
import { OBSERVATION_MATRIX_COLUMN_SINGLE_DESCRIPTOR, DESCRIPTOR_MEDIA } from 'constants/index'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }, { descriptorName, description }) => {
  const descriptor = {
    name: descriptorName,
    description_name: description,
    type: DESCRIPTOR_MEDIA
  }

  Descriptor.create({ descriptor }).then(response => {
    const createdDescriptor = response.body
    const payload = {
      observation_matrix_id: state.observationMatrix.id,
      descriptor_id: createdDescriptor.id,
      type: OBSERVATION_MATRIX_COLUMN_SINGLE_DESCRIPTOR
    }

    ObservationMatrixColumnItem.create({ observation_matrix_column_item: payload }).then(({ body }) => {
      TW.workbench.alert.create('Column item was successfully created.', 'notice')

      commit(MutationNames.AddNewColumn, createdDescriptor)
    }).finally(() => {
      state.isSaving = false
    })
  }).finally(() => {
    state.isSaving = false
  })
}
