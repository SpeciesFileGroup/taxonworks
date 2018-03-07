const removeTaxonSource = require('../../request/resources').removeTaxonSource
const MutationNames = require('../mutations/mutations').MutationNames

module.exports = function ({ commit, state }, citationId) {
  removeTaxonSource(state.taxon_name.id, citationId).then(response => {
    commit(MutationNames.SetCitation, response)
  })
}
