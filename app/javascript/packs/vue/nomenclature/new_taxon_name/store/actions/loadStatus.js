const loadStatus = require('../../request/resources').loadStatus;
const MutationNames = require('../mutations/mutations').MutationNames;

module.exports = function({ commit, state }) {
	return new Promise(function(resolve,reject) {
		loadStatus().then(response => {
			commit(MutationNames.SetStatusList, response);
			return resolve();
		})
	})
};