import setParamsId from '../../helpers/setParamsId';

export default function(state, material) {
	setParamsId('type_material_id', material.id)
	state.type_material = Object.assign({}, state.type_material, material);
};