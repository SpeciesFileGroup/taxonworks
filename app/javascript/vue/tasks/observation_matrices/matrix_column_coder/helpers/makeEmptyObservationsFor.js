import ComponentNames from 'tasks/observation_matrices/matrix_row_coder/store/helpers/ComponentNames'
import ObservationTypes from 'tasks/observation_matrices/matrix_row_coder/store/helpers/ObservationTypes'
import makeObservation from './makeObservation'

const ComponentNamesToObservations = {
  [ComponentNames.Qualitative]: ObservationTypes.Qualitative,
  [ComponentNames.Continuous]: ObservationTypes.Continuous,
  [ComponentNames.Sample]: ObservationTypes.Sample,
  [ComponentNames.Presence]: ObservationTypes.Presence,
  [ComponentNames.Media]: ObservationTypes.Media,
  [ComponentNames.FreeText]: ObservationTypes.FreeText
}

export default function (descriptor, rowObject) {
  const observations = []

  const emptyObservationData = {
    descriptorId: descriptor.id,
    rowObjectId: rowObject.id,
    rowObjectType: rowObject.base_class,
    type: ComponentNamesToObservations[descriptor.componentName]
  }

  if (descriptor.componentName === ComponentNames.Qualitative) {
    descriptor.characterStates.forEach(characterState => {
      const emptyCharacterStateObservationData = Object.assign({}, emptyObservationData, { characterStateId: characterState.id })
      observations.push(makeObservation(emptyCharacterStateObservationData))
    })
  } else if (descriptor.componentName === ComponentNames.Continuous) {
    const emptyContinuousObservationData = Object.assign({}, emptyObservationData, { default_unit: descriptor.default_unit })
    observations.push(makeObservation(emptyContinuousObservationData))
  } else if (descriptor.componentName === ComponentNames.Sample) {
    const emptyContinuousObservationData = Object.assign({}, emptyObservationData, { default_unit: descriptor.default_unit })
    observations.push(makeObservation(emptyContinuousObservationData))
  } else {
    observations.push(makeObservation(emptyObservationData))
  }

  console.log(observations)

  return observations
}
