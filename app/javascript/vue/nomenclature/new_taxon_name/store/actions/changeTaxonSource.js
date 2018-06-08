const changeTaxonSource = require('../../request/resources').changeTaxonSource
const MutationNames = require('../mutations/mutations').MutationNames

module.exports = function ({ commit, state }, source) {
  changeTaxonSource(state.taxon_name.id, source, state.taxon_name.origin_citation).then(response => {
    commit(MutationNames.SetCitation, response)
  })
}
