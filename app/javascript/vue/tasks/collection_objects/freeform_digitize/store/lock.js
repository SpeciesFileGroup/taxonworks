import { defineStore } from 'pinia'

export default defineStore('lock', {
  state: () => ({
    notes: false,
    tags: false,
    repository_id: false,
    identifier: false,
    preparation_type_id: false,
    collectingEvent: false
  })
})
