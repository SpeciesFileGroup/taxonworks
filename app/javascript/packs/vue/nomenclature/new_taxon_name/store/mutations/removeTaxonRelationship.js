module.exports = function(state, status) {
	var position = state.taxon_name.relationshipList.findIndex( item => {
		if(item.type == status.type) {
			return true;
		}
	});
	if (position >= 0) {
		state.taxon_name.relationshipList.splice(position, 1);
	}
};