import { Image } from '@/routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }) => {
  const promises = []

  state.imagesCreated.forEach((image) => {
    promises.push(
      Image.update(image.id, {
        image: {
          id: image.id,
          pixels_to_centimeter: state.pixelsToCentimeter
        }
      }).then(() => {
        commit(MutationNames.MarkApplied, {
          imageIds: [image.id],
          key: 'pixel'
        })
      })
    )
  })

  return Promise.all(promises).then(() => {
    TW.workbench.alert.create('Image(s) was successfully updated.', 'notice')
  })
}
