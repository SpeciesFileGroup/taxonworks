import { defineStore } from 'pinia'

export default defineStore('settings', {
  state: () => ({
    isLoading: false,
    isSaving: false,
    locked: {
      taxonDeterminations: false,
      collectingEvent: false,
      biocurations: false
    }
  })
})
