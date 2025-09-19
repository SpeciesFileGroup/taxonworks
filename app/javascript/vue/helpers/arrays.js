import DOMPurify from 'dompurify'
import { isPureNumber } from './numbers.js'
import { getNestedValue } from './objects.js'

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
  const isNullOrUndefined = (val) => val === null || val === undefined

  if (isNullOrUndefined(a) && isNullOrUndefined(b)) return 0
  if (isNullOrUndefined(a)) return asc ? -1 : 1
  if (isNullOrUndefined(b)) return asc ? 1 : -1

  const aStr = a.toString()
  const bStr = b.toString()

  const bothPureNumbers = isPureNumber(aStr) && isPureNumber(bStr)

  if (bothPureNumbers) {
    const numA = parseFloat(aStr)
    const numB = parseFloat(bStr)
    return asc ? numA - numB : numB - numA
  }

  return asc
    ? aStr.localeCompare(bStr, undefined, {
        numeric: true,
        sensitivity: 'base'
      })
    : bStr.localeCompare(aStr, undefined, {
        numeric: true,
        sensitivity: 'base'
      })
}

function sortArray(arr, sortProperty, ascending = true, opts = {}) {
  const list = arr.slice()
  const path = sortProperty ? String(sortProperty).split('.') : null
  const { stripHtml } = opts

  return list.sort((itemA, itemB) => {
    let a = path ? getNestedValue(itemA, path) : itemA
    let b = path ? getNestedValue(itemB, path) : itemB

    if (stripHtml) {
      a = DOMPurify.sanitize(a, { USE_PROFILES: { html: false } })
      b = DOMPurify.sanitize(b, { USE_PROFILES: { html: false } })
    }

    return sortFunction(a, b, ascending)
  })
}

export function sortArrayByReference({
  list,
  reference,
  getListValue = (item) => item,
  getReferenceValue = (item) => item,
  excludeUnmatched = false
}) {
  const positionMap = new Map(
    reference.map((item, index) => [getReferenceValue(item), index])
  )

  let filteredList = excludeUnmatched
    ? list.filter((item) => positionMap.has(getListValue(item)))
    : list

  return filteredList.toSorted((a, b) => {
    const aKey = getListValue(a)
    const bKey = getListValue(b)
    return (
      (positionMap.get(aKey) ?? Infinity) - (positionMap.get(bKey) ?? Infinity)
    )
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

function intersectArrays(...arrays) {
  // chatgpt 5.0
  if (arrays.length === 0) return []
  return [...new Set(arrays.reduce((acc, arr) => acc.filter(x => new Set(arr).has(x))))]
}

// a - b, removes elements of b from a globally
function subtractArrays(a, b) {
  const bSet = new Set(b)
  return a.filter((e) => !bSet.has(e))
}

export {
  chunkArray,
  getUnique,
  sortArray,
  sortArrayByArray,
  addToArray,
  removeFromArray,
  intersectArrays,
  subtractArrays
}
