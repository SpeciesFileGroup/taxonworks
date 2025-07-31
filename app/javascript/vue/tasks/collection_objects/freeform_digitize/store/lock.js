import { defineStore } from 'pinia'

export default defineStore('lock', {
  state: () => ({
    notes: false,
    tags: false,
    repository: false,
    identifier: false,
    preparationType: false,
    collectingEvent: false,
    taxonDeterminations: false
  })
})
