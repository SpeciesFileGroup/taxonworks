import { MutationNames } from '../mutations/mutations';
import { CreateTypeMaterial } from '../../request/resources';

export default function({ commit, state }) {
	let type_material = state.type_material;

	commit(MutationNames.SetSaving, true);
	if(state.settings.materialTab != 'collection object') {
		type_material.biological_object_id = undefined;
		type_material.material_attributes = state.type_material.collection_object;
	}
	return CreateTypeMaterial({ type_material: type_material }).then(response => {
		TW.workbench.alert.create('Type specimen was successfully created.', 'notice');
		commit(MutationNames.AddTypeMaterial, response);
		commit(MutationNames.SetTypeMaterial, response);
		commit(MutationNames.SetSaving, false);
	})
};