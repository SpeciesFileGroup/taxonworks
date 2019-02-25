import { DestroyImage } from '../../request/resources'

export default function({ state }, image) {
  DestroyImage(image.id).then(response => {
    this.state.imagesCreated.splice(this.state.imagesCreated.findIndex(item => {
      return item.id == image.id
    }), 1)
    TW.workbench.alert.create(`Image was successfully destroyed.`, 'notice')
  })
}