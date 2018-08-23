const updateTaxonRelationship = require('../../request/resources').updateTaxonRelationship
const MutationNames = require('../mutations/mutations').MutationNames

module.exports = function ({ commit, state, dispatch }, relationship) {
  let patchRelationship = {
    taxon_name_relationship: relationship
  }
  updateTaxonRelationship(patchRelationship).then(response => {
    commit(MutationNames.AddTaxonRelationship, response)
    dispatch('loadSoftValidation', 'taxon_name')
    dispatch('loadSoftValidation', 'taxonRelationshipList')
  })
}
