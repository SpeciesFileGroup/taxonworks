import { Image } from '@/routes/endpoints'

export default ({ state }) => {
  const promises = []

  state.imagesCreated.forEach((image) => {
    promises.push(
      Image.update(image.id, {
        image: {
          id: image.id,
          pixels_to_centimeter: state.pixelsToCentimeter
        }
      })
    )
  })

  Promise.all(promises).then(() => {
    state.settings.applied.pixel = true
    TW.workbench.alert.create('Image(s) was successfully updated.', 'notice')
  })
}
