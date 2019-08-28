const getDate = (d) => {

  if (!d) return undefined
  let day, month, year, result, aux, dateSplitted

  result = d.match('[0-9]{2}([\-/ \.])[0-9]{2}[\-/ \.][0-9]{4}')
  if (result != null) {
    dateSplitted = result[0].split(result[1])
    day = dateSplitted[0]
    month = dateSplitted[1]
    year = dateSplitted[2]
  }
  result = d.match('[0-9]{4}([\-/ \.])[0-9]{2}[\-/ \.][0-9]{2}')
  if (result != null) {
    dateSplitted = result[0].split(result[1])
    day = dateSplitted[2]
    month = dateSplitted[1]
    year = dateSplitted[0]
  }

  if (month > 12) {
    aux = day
    day = month
    month = aux
  }

  return (year && month && day) ? year + '/' + month + '/' + day : undefined
}

export default getDate
