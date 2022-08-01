import { ObservationMatrix } from 'routes/endpoints'
import ActionNames from './actionNames'
import ComponentNames from 'tasks/observation_matrices/matrix_row_coder/store/helpers/ComponentNames'
import DescriptorTypes from 'tasks/observation_matrices/matrix_row_coder/store/helpers/DescriptorTypes'
import makeEmptyObservationsFor from '../../helpers/makeEmptyObservationsFor.js'
import makeRowObject from '../../helpers/makeRowObject'

export default async ({ dispatch, state }, id) => {
  ObservationMatrix.objectsByColumnId(id).then(({ body }) => {
    state.observationMatrix = body.observation_matrix
    state.descriptor = makeDescriptor(body.descriptor)
    state.rowObjects = [
      ...body.otus,
      ...body.collection_objects
    ].map(o => makeRowObject(o))

    state.rowObjects.forEach(rowObject => {
      state.observations = [...state.observations, ...makeEmptyObservationsFor(state.descriptor, rowObject)]
    })

    dispatch(ActionNames.LoadObservations, getObservationParameters(state.descriptor))
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
  const descriptor = {
    id: descriptorData.id,
    componentName: getComponentNameForDescriptorType(descriptorData),
    title: descriptorData.object_tag,
    globalId: descriptorData.global_id,
    type: getComponentNameForDescriptorType(descriptorData)
  }

  if (descriptor.type === ComponentNames.Qualitative) {
    Object.assign(descriptor, { characterStates: descriptorData.character_states })
  }

  return descriptor
}

function getObservationParameters (descriptor) {
  const payload = {
    descriptor_id: descriptor.id,
    per: 5000
  }

  if (descriptor.type === ComponentNames.Media) {
    Object.assign(payload, { extend: ['depictions'] })
  }

  return payload
}
