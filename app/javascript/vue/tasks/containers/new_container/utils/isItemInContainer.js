export function isItemInContainer({ x, y, z }, size) {
  return (
    x !== null &&
    y !== null &&
    z !== null &&
    x < size.x &&
    y < size.y &&
    z < size.z
  )
}
