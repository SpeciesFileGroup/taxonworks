import { defineStore } from 'pinia'

export default defineStore('settings', {
  state: () => ({
    isLoading: false,
    isSaving: false,
    locked: {
      biocurations: false,
      citations: false,
      collectingEvent: false,
      taxonDeterminations: false,
      namespace: false
    }
  })
})
