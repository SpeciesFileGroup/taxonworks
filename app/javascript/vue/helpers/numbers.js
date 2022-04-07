export function convertToTwoDigits (number) {
  return Number(number).toLocaleString('en-US', {
    minimumIntegerDigits: 2,
    useGrouping: false
  })
}
