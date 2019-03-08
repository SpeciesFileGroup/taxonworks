import parseDMS from 'parse-dms'

function foundCoordinate(coordinates) {
  let keys = Object.keys(coordinates)
  let key = keys.find(key => {
    return coordinates[key] != undefined
  })
  
  return key ? coordinates[key] : undefined
}

export default function(coord) {
  let newCoord = coord
  if(newCoord && isNaN(newCoord)) {
    try {
      newCoord = parseDMS(newCoord)
      newCoord = foundCoordinate(newCoord)
      return newCoord
    }
    catch(error) {
      return undefined
    }
  }
  else {
    return newCoord
  }
}