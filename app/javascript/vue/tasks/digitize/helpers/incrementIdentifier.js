export default function(textString) {
  if(textString == undefined || !(/(\d+)/g).test(textString)) return textString

  let numbers = textString.match(/(\d+)/g).map(Number)
  let index = numbers.length-1
  let newValue = numbers[index] + 1
  let start = textString.lastIndexOf(numbers[index])
  let numberLength = numbers[index].toString().length

  return textString.substring(0, start) + newValue + textString.substring((start + numberLength), textString.length)
}