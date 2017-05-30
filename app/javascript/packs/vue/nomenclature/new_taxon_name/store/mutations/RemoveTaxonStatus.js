module.exports = function(state, status) {
	var position = state.taxon_name.statusList.findIndex( item => {
		if(item.type == status.type) {
			return true;
		}
	});
	if (position >= 0) {
		state.taxon_name.statusList.splice(position, 1);
	}
};