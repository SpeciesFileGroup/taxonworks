var findPosition = require('./findPosition')

module.exports = function (list, rank) {
  return list.slice(findPosition(list, rank) + 1)
}
