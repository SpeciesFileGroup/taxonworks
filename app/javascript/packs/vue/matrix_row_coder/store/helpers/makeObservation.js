import makeBaseObservation from './makeBaseObservation';
import makeQualitativeObservation from './makeQualitativeObservation';
import makeContinuousObservation from './makeContinuousObservation';
import makePresenceObservation from './makePresenceObservation';
import makeSampleObservation from './makeSampleObservation';
import ObservationTypes from './ObservationTypes';

export default function(observationData) {
    if (observationData.type === ObservationTypes.Qualitative)
        return makeQualitativeObservation(observationData);
    else if (observationData.type === ObservationTypes.Continuous)
        return makeContinuousObservation(observationData);
    else if (observationData.type === ObservationTypes.Presence)
        return makePresenceObservation(observationData);
    else if (observationData.type === ObservationTypes.Sample)
        return makeSampleObservation(observationData);
    return makeBaseObservation(observationData);
}