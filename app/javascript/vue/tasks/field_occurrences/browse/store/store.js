import { FieldOccurrence } from '@/routes/endpoints'
import { defineStore } from 'pinia'

export default defineStore('browseFieldOccurrence', {
  state: () => ({
    fieldOccurrence: null
  }),

  actions: {
    async load(fieldOccurrenceId) {
      return FieldOccurrence.find(fieldOccurrenceId)
        .then(({ body }) => {
          this.fieldOccurrence = body
        })
        .catch(() => {})
    }
  }
})
