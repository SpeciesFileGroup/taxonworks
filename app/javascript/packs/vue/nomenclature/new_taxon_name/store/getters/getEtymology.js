module.exports = function(state) {
	return (state.taxon_name.etymology == null ? '' : state.taxon_name.etymology);
};