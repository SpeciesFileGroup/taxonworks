function chunkArray (myArray, chunkSize) {
  var results = []

  while (myArray.length) {
    results.push(myArray.splice(0, chunkSize))
  }

  return results
}

export {
  chunkArray
}
