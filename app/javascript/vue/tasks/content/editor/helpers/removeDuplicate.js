export default function (list, id) {
  var
    position = list.findIndex(item => {
      if (id === item.id) {
        return true
      }
    })
  if (position >= 0) {
    list.splice(position, 1)
  }
  return list
}
