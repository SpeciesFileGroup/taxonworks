import ajaxCall from 'helpers/ajaxCall'

const GetImage = function(id) {
  return ajaxCall('get', `/images/${id}.json`)
}

export {
  GetImage
}