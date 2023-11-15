import { defineStore } from 'pinia'

export default defineStore('lock', {
  state: () => ({
    notes_attributes: false,
    tags_attributes: false,
    repository_id: false,
    identifier: false,
    preparation_type_id: false
  })
})
