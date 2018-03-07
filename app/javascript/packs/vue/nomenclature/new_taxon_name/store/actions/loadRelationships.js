const loadRelationships = require('../../request/resources').loadRelationships
const MutationNames = require('../mutations/mutations').MutationNames

module.exports = function ({ commit, state }) {
  return new Promise(function (resolve, reject) {
    loadRelationships().then(response => {
      commit(MutationNames.SetRelationshipList, response)
      return resolve()
    })
  })
}
