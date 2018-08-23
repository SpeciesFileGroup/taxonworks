const loadTaxonRelationships = require('../../request/resources').loadTaxonRelationships
const MutationNames = require('../mutations/mutations').MutationNames

module.exports = function ({ commit, state, dispatch }, id) {
  return new Promise(function (resolve, reject) {
    loadTaxonRelationships(id).then(response => {
      commit(MutationNames.SetTaxonRelationshipList, response)
      dispatch('loadSoftValidation', 'taxonRelationshipList')
      return resolve()
    })
  })
}
