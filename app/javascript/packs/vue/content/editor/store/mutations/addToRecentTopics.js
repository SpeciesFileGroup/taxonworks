module.exports = function(state, item) {
	state.recent.topics.unshift(item);
};