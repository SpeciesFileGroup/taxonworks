export default function selectFirstSmartOption(lists, keys) {
  return keys.find((key) => {
    return lists[key].length > 0 || lists[key] == undefined
  })
}