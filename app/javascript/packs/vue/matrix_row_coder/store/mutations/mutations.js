export const MutationNames = {
    SetDescriptors: 'setDescriptors',
    SetTaxonTitle: 'setTaxonTitle',
    SetTaxonId: 'setTaxonId',
    SetConfidenceLevels: 'setConfidenceLevels',
    SetObservation: 'setObservation',
    SetDescriptorNotes: 'setDescriptorNotes',
    SetDescriptorDepictions: 'setDescriptorDepictions',
    SetObservationNotes: 'setObservationNotes',
    SetObservationDepictions: 'setObservationDepictions',
    SetObservationConfidences: 'setObservationConfidences',
    SetObservationCitations: 'setObservationCitations',
    SetDescriptorZoom: 'setDescriptorZoom',
    SetContinuousValue: 'setContinuousValue',
    SetContinuousUnit: 'setContinuousUnit',
    SetPresence: 'setPresence',
    SetCharacterStateChecked: 'setCharacterStateChecked',
    SetSampleMaxFor: `setSampleMaxFor`,
    SetSampleMinFor: `setSampleMinFor`,
    SetSampleNFor: `setSampleNFor`,
    SetSampleUnitFor: `setSampleUnitFor`,
    ClearObservation: 'clearObservation',
    ObservationSaved: `observationSaved`,
    CountdownStartedFor: `countdownStartedFor`,
    SetDescriptorSaving: `setDescriptorSaving`,
    SetDescriptorSavedOnce: `setDescriptorSavedOnce`,
    SetObservationId: `setObservationId`
};

import setDescriptors from './setDescriptors';
import setTaxonTitle from './setTaxonTitle';
import setTaxonId from './setTaxonId';
import setConfidenceLevels from './setConfidenceLevels';
import setObservation from './setObservation';
import setDescriptorNotes from './setDescriptorNotes';
import setDescriptorDepictions from './setDescriptorDepictions';
import setObservationNotes from './setObservationNotes';
import setObservationDepictions from './setObservationDepictions';
import setObservationConfidences from './setObservationConfidences';
import setObservationCitations from './setObservationCitations';
import setDescriptorZoom from './setDescriptorZoom';
import setContinuousValue from './setContinuousValue';
import setContinuousUnit from './setContinuousUnit';
import setPresence from './setPresence';
import setCharacterStateChecked from './setCharacterStateChecked';
import setSampleMaxFor from './setSampleMaxFor';
import setSampleMinFor from './setSampleMinFor';
import setSampleNFor from './setSampleNFor';
import setSampleUnitFor from './setSampleUnitFor';
import clearObservation from './clearObservation';
import observationSaved from './observationSaved';
import countdownStartedFor from './countdownStartedFor';
import setDescriptorSaving from './setDescriptorSaving';
import setDescriptorSavedOnce from './setDescriptorSavedOnce';
import setObservationId from './setObservationId';

export const MutationFunctions = {
    [MutationNames.SetDescriptors]: setDescriptors,
    [MutationNames.SetTaxonTitle]: setTaxonTitle,
    [MutationNames.SetTaxonId]: setTaxonId,
    [MutationNames.SetConfidenceLevels]: setConfidenceLevels,
    [MutationNames.SetObservation]: setObservation,
    [MutationNames.SetDescriptorNotes]: setDescriptorNotes,
    [MutationNames.SetDescriptorDepictions]: setDescriptorDepictions,
    [MutationNames.SetObservationNotes]: setObservationNotes,
    [MutationNames.SetObservationDepictions]: setObservationDepictions,
    [MutationNames.SetObservationConfidences]: setObservationConfidences,
    [MutationNames.SetObservationCitations]: setObservationCitations,
    [MutationNames.SetDescriptorZoom]: setDescriptorZoom,
    [MutationNames.SetContinuousValue]: setContinuousValue,
    [MutationNames.SetContinuousUnit]: setContinuousUnit,
    [MutationNames.SetPresence]: setPresence,
    [MutationNames.SetCharacterStateChecked]: setCharacterStateChecked,
    [MutationNames.SetSampleMaxFor]: setSampleMaxFor,
    [MutationNames.SetSampleMinFor]: setSampleMinFor,
    [MutationNames.SetSampleNFor]: setSampleNFor,
    [MutationNames.SetSampleUnitFor]: setSampleUnitFor,
    [MutationNames.ClearObservation]: clearObservation,
    [MutationNames.ObservationSaved]: observationSaved,
    [MutationNames.CountdownStartedFor]: countdownStartedFor,
    [MutationNames.SetDescriptorSaving]: setDescriptorSaving,
    [MutationNames.SetDescriptorSavedOnce]: setDescriptorSavedOnce,
    [MutationNames.SetObservationId]: setObservationId
};