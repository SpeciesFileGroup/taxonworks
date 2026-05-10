export function displayType(type) {
  if (!type) return ''
  return type.split('::').slice(1).join('::')
}
