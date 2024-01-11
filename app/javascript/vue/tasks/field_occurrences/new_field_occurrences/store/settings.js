import { defineStore } from 'pinia'

export default defineStore('settings', {
  state: () => ({
    settings: {
      isLoading: false,
      isSaving: false,
      lastChange: 0,
      lastSave: 0
    }
  })
})
