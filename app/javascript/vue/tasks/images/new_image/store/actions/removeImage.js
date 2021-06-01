import { Image } from 'routes/endpoints'

export default ({ state }, image) => {
  Image.destroy(image.id).then(() => {
    state.imagesCreated.splice(state.imagesCreated.findIndex(item => item.id === image.id), 1)
    TW.workbench.alert.create('Image was successfully destroyed.', 'notice')
  })
}