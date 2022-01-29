
// Taken directly from http://forwebonly.com/capitalize-the-first-letter-of-a-string-in-javascript-the-fast-way/
function capitalize(string) {
  return string.charAt(0).toUpperCase() + string.substring(1);
}

function insertStringInPosition(string, addString, index) {
  return string.substring(0, index) + addString + string.substring(index);
}

String.prototype.toPascalCase = function () {
  return this.match(/[a-z0-9]+/gi)
    .map(function (word) {
      return word.charAt(0).toUpperCase() + word.substr(1).toLowerCase()
    })
  .join('')
}