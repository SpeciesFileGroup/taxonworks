export default function (prop, arr, ascending = true) {
  prop = prop.split('.')
  var len = prop.length

  arr.sort(function (a, b) {
    var i = 0
    while( i < len ) { a = a[prop[i]]; b = b[prop[i]]; i++; }
    if (a < b) {
      return (ascending ? -1 : 1)
    } else if (a > b) {
      return (ascending ? 1 : -1)
    } else {
      return 0
    }
  })
  
  return arr
}