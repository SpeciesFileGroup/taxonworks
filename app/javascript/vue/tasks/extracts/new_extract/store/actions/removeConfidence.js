import { removeFromArray } from '@/helpers'
import { Confidence } from '@/routes/endpoints'

export default ({ state }, item) => {
  removeFromArray(state.confidences, item, { property: 'uuid' })

  if (item.id) {
    Confidence.destroy(item.id)
      .then(() => {
        TW.workbench.alert.create(
          'Confidence item was successfully destroyed.',
          'notice'
        )
      })
      .catch(() => {})
  }
}
