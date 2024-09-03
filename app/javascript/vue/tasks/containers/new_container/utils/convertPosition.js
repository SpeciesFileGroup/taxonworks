export function convertPositionToTWCoordinates(position, size) {
  return {
    ...position,
    y: size.y - position.y - 1
  }
}

export function convertPositionTo3DGraph(position, size) {
  return {
    ...position,
    y: Math.abs(position.y - size.y + 1)
  }
}
