import parseDMS from 'parse-dms'

function foundCoordinate(coordinates) {
  let keys = Object.keys(coordinates)
  let key = keys.find((key) => {
    return coordinates[key] != undefined
  })

  return key ? coordinates[key] : undefined
}

export default function (coord) {
  if (coord == null) return undefined

  const value = coord.toString().trim()

  if (!value) return undefined

  const numeric = Number(value)

  if (Number.isFinite(numeric)) {
    return numeric
  }

  try {
    const parsed = parseDMS(value)

    if (typeof parsed === 'number') {
      return parsed
    }

    return foundCoordinate(parsed)
  } catch {
    return undefined
  }
}
