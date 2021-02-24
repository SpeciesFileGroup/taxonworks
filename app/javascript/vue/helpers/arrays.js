function chunkArray (myArray, chunkSize) {
  var results = []

  while (myArray.length) {
    results.push(myArray.splice(0, chunkSize))
  }

  return results
}

function getUnique (arr, property) {
  return [...new Map(arr.map(item => [item[property], item])).values()]
}

export {
  chunkArray,
  getUnique
}
