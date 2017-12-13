import setType from './setType';
import setBiologicalId from './setBiologicalId';
import setCitation from './setCitation';
import setRoles from './setRoles';
import setSaving from './setSaving';

const MutationNames = {
	SetType: 'setType',
	SetBiologicalId: 'setBiologicalId',
	SetCitation: 'setCitation',
	SetRoles: 'setRoles',
	SetSaving: 'setSaving'
};

const MutationFunctions = {
	[MutationNames.SetType]: setType,
	[MutationNames.SetBiologicalId]: setBiologicalId,
	[MutationNames.SetCitation]: setCitation,
	[MutationNames.SetRoles]: setRoles,
	[MutationNames.SetSaving]: setSaving
};

export {
	MutationNames,
	MutationFunctions
}