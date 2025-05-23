import DOMPurify from 'dompurify'

function chunkArray(arr, chunkSize) {
  const results = []
  const tmpArr = arr.slice()

  while (tmpArr.length) {
    results.push(tmpArr.splice(0, chunkSize))
  }

  return results
}

function getUnique(arr, property) {
  return [...new Map(arr.map((item) => [item[property], item])).values()]
}

function sortFunction(a, b, asc) {
  if (a == null && b == null) return 0

  if (asc) {
    if (a == null) return -1
    if (b == null) return 1
  } else {
    if (a == null) return 1
    if (b == null) return -1
  }

  const numA = parseFloat(a)
  const numB = parseFloat(b)

  if (!isNaN(numA) && !isNaN(numB)) {
    return asc ? numA - numB : numB - numA
  }

  return asc
    ? a.toString().localeCompare(b.toString(), undefined, {
        numeric: true,
        sensitivity: 'base'
      })
    : b.toString().localeCompare(a.toString(), undefined, {
        numeric: true,
        sensitivity: 'base'
      })
}

function sortArray(arr, sortProperty, ascending = true, opts = {}) {
  const list = arr.slice()
  const prop = String(sortProperty).split('.')
  const len = prop.length

  const { stripHtml } = opts

  return list.sort((a, b) => {
    if (!sortProperty) return sortFunction(a, b, ascending)

    for (let i = 0; i < len; i++) {
      if (a) {
        a = a[prop[i]]
      }
      if (b) {
        b = b[prop[i]]
      }
    }

    if (stripHtml) {
      a = DOMPurify.sanitize(a, { USE_PROFILES: { html: false } })
      b = DOMPurify.sanitize(b, { USE_PROFILES: { html: false } })
    }

    return sortFunction(a, b, ascending)
  })
}

function sortArrayByArray(arr, sortingArr, asc) {
  const list = arr.slice()

  list.sort((a, b) =>
    sortFunction(sortingArr.indexOf(a), sortingArr.indexOf(b), asc)
  )

  return list
}

function addToArray(arr, obj, opts = {}) {
  const { property = 'id', prepend = false, primitive = false } = opts

  const index = primitive
    ? arr.findIndex((item) => obj === item)
    : arr.findIndex((item) => obj[property] === item[property])

  if (index > -1) {
    arr[index] = obj
  } else {
    if (prepend) {
      arr.unshift(obj)
    } else {
      arr.push(obj)
    }
  }
}

function removeFromArray(arr, obj, opts = {}) {
  const { property = 'id', primitive = false } = opts
  const index = primitive
    ? arr.findIndex((item) => obj === item)
    : arr.findIndex((item) => obj[property] === item[property])

  if (index > -1) {
    arr.splice(index, 1)
  }
}

export {
  chunkArray,
  getUnique,
  sortArray,
  sortArrayByArray,
  addToArray,
  removeFromArray
}
