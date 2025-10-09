export function listParser(list) {
  return list.map((item) => ({
    ...item,
    serial: item.serial?.name || ''
  }))
}
