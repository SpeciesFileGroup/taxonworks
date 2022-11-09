import { reactive } from 'vue'
import { CollectionObject } from 'routes/endpoints'

const state = reactive({
  collectingEvent: {},
  collectionObject: {},
  identifier: {}
})

export default () => {
  const getters = {
    getCollectingEvent: () => state.collectingEvent
  }

  const actions = {
    createCollectionObject: () => {
      CollectionObject.create({
        collection_object: {
          ...state.collectionObject,
          collecting_event_id: state.collectingEvent.id
        }
      })
    }
  }

  return {
    getters,
    actions,
    state
  }
}
