module.exports = function(state, status) {
	var position = state.taxonRelationshipList.findIndex( item => {
		if(item.type == status.type) {
			return true;
		}
	});
	
	if (position < 0) {
		state.taxonRelationshipList.push(status);
	}
};