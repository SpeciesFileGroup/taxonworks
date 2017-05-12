module.exports = function(list,rankName) {
  var found = '';
  for(var groupName in list) {
    list[groupName].find(function(item) {
      if(rankName == item.name) {
        found = groupName;
      }
    });
  }
  return found;
} 
