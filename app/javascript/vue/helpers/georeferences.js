import { replaceAt } from 'helpers/strings.js'

const replaceCharacters = [
  ['ʺ', '"'],
  ['ʹ', "'"]
]

function parseCoordinateCharacters (coordinate) {
  replaceCharacters.forEach(([original, newChar]) => {
    const index = coordinate.indexOf(original)

    coordinate = replaceAt(index, coordinate, newChar)
  })

  return coordinate
}

export {
  parseCoordinateCharacters
}
