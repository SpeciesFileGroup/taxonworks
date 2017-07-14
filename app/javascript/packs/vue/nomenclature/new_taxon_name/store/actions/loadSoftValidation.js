const loadSoftValidation = require('../../request/resources').loadSoftValidation;
const MutationNames = require('../mutations/mutations').MutationNames;  

module.exports = function({ commit, state }) {
  loadSoftValidation(state.taxon_name.global_id).then( response => {
    commit(MutationNames.SetSoftValidation, response);
  });
};