export default function (list, name) {
  return list.findIndex(item => {
    if (item.name == name) {
      return true
    }
  })
}
