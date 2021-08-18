export default function (textString) {
  if (textString === undefined || !(/(\d+)/g).test(textString)) return textString

  const numberString = textString.match(/(\d+)/g).pop() // get the last group of numbers in the string

  const number = parseInt(numberString, 10) + 1
  const newValue = number.toString().padStart(numberString.length, '0') // keep the number the same length as before

  const start = textString.lastIndexOf(numberString)
  const prefix = textString.substring(0, start)
  const postfix = textString.substring(start + numberString.length)

  return prefix + newValue + postfix
}
