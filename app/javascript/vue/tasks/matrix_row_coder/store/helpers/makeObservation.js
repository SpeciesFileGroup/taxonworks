import makeBaseObservation from './makeBaseObservation'
import makeContinuousObservation from './makeContinuousObservation'
import makeFreeTextObservation from './makeFreeTextObservation'
import makeMediaObservation from './makeMediaObservation'
import makePresenceObservation from './makePresenceObservation'
import makeSampleObservation from './makeSampleObservation'
import makeQualitativeObservation from './makeQualitativeObservation'
import ObservationTypes from './ObservationTypes'

export default function (observationData) {
  if (observationData.type === ObservationTypes.Qualitative) { 
    return makeQualitativeObservation(observationData)
  } else if (observationData.type === ObservationTypes.Continuous) { 
    return makeContinuousObservation(observationData)
  } else if (observationData.type === ObservationTypes.Presence) { 
    return makePresenceObservation(observationData)
  } else if (observationData.type === ObservationTypes.Sample) { 
    return makeSampleObservation(observationData)
  } else if (observationData.type === ObservationTypes.Media) {
    return makeMediaObservation(observationData)
  } else if (observationData.type === ObservationTypes.FreeText) {
    return makeFreeTextObservation(observationData)
  }
  return makeBaseObservation(observationData)
}
