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
  const prop = sortProperty.split('.')
  const len = prop.length

  return list.sort((a, b) => {
    let i = 0
    
    for (let i = 0; i < len; i++) {
      a = a[prop[i]]
      b = b[prop[i]]
    }

    if (a === null) return 1
    if (b === null) return -1
    if (a === null && b === null) return 0

    const result = a - b

    if (isNaN(result)) {
      return (ascending)
        ? a.toString().localeCompare(b, undefined, { numeric: true, sensitivity: 'base' })
        : b.toString().localeCompare(a, undefined, { numeric: true, sensitivity: 'base' })
    } else {
      return (ascending) ? result : -result
    }
  })
}

function addToArray (arr, obj, property = 'id') {
  const index = arr.findIndex(item => obj[property] === item[property])

  if (index > -1) {
    arr[index] = obj
  } else {
    arr.push(obj)
  }
}

function removeFromArray (arr, obj, property = 'id') {
  const index = arr.findIndex(item => obj[property] === item[property])

  if (index > -1) {
    arr.splice(index, 1)
  }
}

export {
  chunkArray,
  getUnique,
  sortArray,
  addToArray,
  removeFromArray
}
