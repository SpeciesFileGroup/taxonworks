import ComponentNames from './ComponentNames';
import ObservationTypes from './ObservationTypes';
import makeObservation from './makeObservation';

const ComponentNamesToObservations = {
    [ComponentNames.Qualitative]: ObservationTypes.Qualitative,
    [ComponentNames.Continuous]: ObservationTypes.Continuous,
    [ComponentNames.Sample]: ObservationTypes.Sample,
    [ComponentNames.Presence]: ObservationTypes.Presence
};

export default function(descriptor) {
    const observations = [];

    const emptyObservationData = {
        descriptorId: descriptor.id,
        type: ComponentNamesToObservations[descriptor.componentName]
    };

    if (descriptor.componentName === ComponentNames.Qualitative) {
        descriptor.characterStates.forEach(characterState => {
            const emptyCharacterStateObservationData = Object.assign({}, emptyObservationData, { characterStateId: characterState.id });
            observations.push(makeObservation(emptyCharacterStateObservationData));
        });
    } else
        observations.push(makeObservation(emptyObservationData));

    return observations;
};