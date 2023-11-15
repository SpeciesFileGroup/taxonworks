import { defineStore } from 'pinia'

export default defineStore('notes', {
  state: () => ({
    notes: []
  })
})
