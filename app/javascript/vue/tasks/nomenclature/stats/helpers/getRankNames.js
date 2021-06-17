export default (list, nameList = []) => {
  for (const key in list) {
    if (typeof list[key] === 'object') {
      this.getRankNames(list[key], nameList)
    } else {
      if (key === 'name') {
        nameList.push(list[key])
      }
    }
  }
  return nameList
}
