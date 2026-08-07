import makeBaseObservation from './makeBaseObservation'

export default function (observationData) {
  const observation = makeBaseObservation(observationData)
  return Object.assign(observation, {
    continuousValue: attemptGetContinuousValueFromData(),
    continuousUnit: observationData.continuous_unit || observationData.default_unit
  })

  function attemptGetContinuousValueFromData () {
    return observationData?.continuous_value || null
  }
};
