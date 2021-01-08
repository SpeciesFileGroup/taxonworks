import { UpdateImage } from '../../request/resources'

export default ({ state, commit }) => {
  const promises = []

  state.imagesCreated.forEach(image => {
    promises.push(UpdateImage({
      id: image.id,
      pixels_to_centimeter: state.pixels_to_centimeter
    }))
  })

  Promise.all(promises).then(() => {
    TW.workbench.alert.create('Image(s) was successfully updated.', 'notice')
  })
}
