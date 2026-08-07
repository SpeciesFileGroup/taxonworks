export function convertToTwoDigits(number) {
  return Number(number).toLocaleString('en-US', {
    minimumIntegerDigits: 2,
    useGrouping: false
  })
}

export function isPureNumber(value) {
  return typeof value === 'number' || /^\s*-?\d+(\.\d+)?\s*$/.test(value)
}
