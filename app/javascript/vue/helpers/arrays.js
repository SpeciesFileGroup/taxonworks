function chunkArray (arr, chunkSize) {
  const results = []
  const tmpArr = arr.slice()

  while (tmpArr.length) {
    results.push(tmpArr.splice(0, chunkSize))
  }

  return results
}

function getUnique (arr, property) {
  return [...new Map(arr.map(item => [item[property], item])).values()]
}

function sortArray (arr, sortProperty, ascending = true) {
  const list = arr.slice()
  return list.sort((A, B) => {
    const a = A[sortProperty]
    const b = B[sortProperty]
    let result

    if (a === null) return 1
    if (b === null) return -1
    if (a === null && b === null) return 0

    result = a - b

    if (isNaN(result)) {
      return (ascending)
        ? a.toString().localeCompare(b, undefined, { numeric: true, sensitivity: 'base' })
        : b.toString().localeCompare(a, undefined, { numeric: true, sensitivity: 'base' })
    }
    else {
      return (ascending) ? result : -result
    }
  })
}

export {
  chunkArray,
  getUnique,
  sortArray
}
