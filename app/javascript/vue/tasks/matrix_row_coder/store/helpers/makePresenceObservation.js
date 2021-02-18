import makeBaseObservation from './makeBaseObservation'

export default function (observationData) {
  const observation = makeBaseObservation(observationData)
  return Object.assign(observation, {
    isChecked: observationData.presence
  })
};
