export default function (list, rankName) {
  var found = undefined
  for (var groupName in list) {
    list[groupName].find(function (item) {
      if (rankName == item.name) {
        found = groupName
      }
    })
  }
  return found
}
