import setType from './setType';
import setBiologicalId from './setBiologicalId';
import setCitation from './setCitation';
import setRoles from './setRoles';
import setProtonymId from './setProtonymId';
import setSaving from './setSaving';

const MutationNames = {
	SetType: 'setType',
	SetBiologicalId: 'setBiologicalId',
	SetCitation: 'setCitation',
	SetRoles: 'setRoles',
	SetProtonymId: 'setProtonymId',
	SetSaving: 'setSaving'
};

const MutationFunctions = {
	[MutationNames.SetType]: setType,
	[MutationNames.SetBiologicalId]: setBiologicalId,
	[MutationNames.SetCitation]: setCitation,
	[MutationNames.SetRoles]: setRoles,
	[MutationNames.SetProtonymId]: setProtonymId,
	[MutationNames.SetSaving]: setSaving
};

export {
	MutationNames,
	MutationFunctions
}