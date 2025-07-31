export function convertPositionToTWCoordinates(position, size) {
  return {
    ...position,
    y: size.y - position.y - 1
  }
}

export function convertPositionTo3DGraph(position, size) {
  const posY = position.y

  return {
    ...position,
    y: size.y <= posY ? posY : Math.abs(size.y - position.y - 1)
  }
}
