import makeBaseObservation from './makeBaseObservation';

export default function(observationData) {
    const observation = makeBaseObservation(observationData);
    return Object.assign(observation, {
        continuousValue: attemptGetContinuousValueFromData(),
        continuousUnit: observationData.continuous_unit || null
    });

    function attemptGetContinuousValueFromData() {
        return observationData.hasOwnProperty('continuous_value') ? observationData.continuous_value : null;
    }
};