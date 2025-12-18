import { defineStore } from 'pinia'

export const useSettingStore = defineStore('settings', {
  state: () => ({
    saving: false,
    isConverting: false,
    loading: false,
    lock: {
      type: false,
      language_id: false,
      serial_id: false,
      bibtex_type: false
    },
    addToSource: false,
    sortable: false,
    preferences: {}
  })
})
