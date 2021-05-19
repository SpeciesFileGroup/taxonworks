function imageSVGViewBox (id, box, imageWidth, imageHeight) {
  const [x, y, width, height] = box.split(' ')
  return `/images/${id}/scale_to_box/${Math.floor(x)}/${Math.floor(y)}/${Math.floor(width)}/${Math.floor(height)}/${imageWidth}/${imageHeight}`
}

function imageScale (id, box, imageWidth, imageHeight) {
  const [x, y, width, height] = box.split(' ')
  return `/images/${id}/scale/${Math.floor(x)}/${Math.floor(y)}/${Math.floor(width)}/${Math.floor(height)}/${imageWidth}/${imageHeight}`
}

export {
  imageSVGViewBox,
  imageScale
}
