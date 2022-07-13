import { ObservationMatrix } from 'routes/endpoints'
import ActionNames from './actionNames'
import ComponentNames from 'tasks/observation_matrices/matrix_row_coder/store/helpers/ComponentNames'
import DescriptorTypes from 'tasks/observation_matrices/matrix_row_coder/store/helpers/DescriptorTypes'

export default async ({ dispatch, state }, id) => {
  ObservationMatrix.objectsByColumnId(id).then(({ body }) => {
    state.observationMatrix = body.observation_matrix
    state.descriptor = makeDescriptor(body.descriptor)
    state.otus = body.otus
    state.collection_objects = body.collection_objects

    dispatch(ActionNames.LoadObservations, body.descriptor.id)
  })
}

const DescriptorTypesToComponentNames = {
  [DescriptorTypes.FreeText]: ComponentNames.FreeText,
  [DescriptorTypes.Media]: ComponentNames.Media,
  [DescriptorTypes.Qualitative]: ComponentNames.Qualitative,
  [DescriptorTypes.Continuous]: ComponentNames.Continuous,
  [DescriptorTypes.Sample]: ComponentNames.Sample,
  [DescriptorTypes.Presence]: ComponentNames.Presence
}

function getComponentNameForDescriptorType (descriptorData) {
  return DescriptorTypesToComponentNames[descriptorData.type]
}

function makeDescriptor (descriptorData) {
  return {
    id: descriptorData.id,
    componentName: getComponentNameForDescriptorType(descriptorData),
    title: descriptorData.object_tag,
    globalId: descriptorData.global_id,
    type: getComponentNameForDescriptorType(descriptorData)
  }
}
