import ajaxCall from 'helpers/ajaxCall'

const GetImage = function(id) {
  return ajaxCall('get', `/images/${id}.json`)
}

const ProcessOCR = (id, x, y, height, width) => {
  return ajaxCall('get', `/images/${id}/ocr/${x}/${y}/${height}/${width}`)
}

export {
  GetImage,
  ProcessOCR
}