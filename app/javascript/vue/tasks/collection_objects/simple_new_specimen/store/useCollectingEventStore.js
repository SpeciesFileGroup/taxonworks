import { CollectingEvent } from 'routes/endpoints'
import { defineStore } from 'pinia'
import makeCollectingEvent from 'factory/CollectingEvent'

export const useCollectingEventStore = defineStore('collectingEvent', {
  state: () => ({
    collectingEvent: makeCollectingEvent()
  }),

  actions: {
    createCollectingEvent () {
      CollectingEvent.create({
        collection_object: {
          ...this.collectionObject,
          collecting_event_id: this.collectingEvent.id
        }
      })
    }
  }
})
