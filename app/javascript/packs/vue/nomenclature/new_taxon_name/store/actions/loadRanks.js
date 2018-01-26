const loadRanks = require('../../request/resources').loadRanks
const MutationNames = require('../mutations/mutations').MutationNames

module.exports = function ({ commit, state }) {
  return new Promise(function (resolve, reject) {
    loadRanks().then(response => {
      commit(MutationNames.SetRankList, response)
      return resolve()
    })
  })
}
