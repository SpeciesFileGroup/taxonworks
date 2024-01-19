import { defineStore } from 'pinia'
import { makeFieldOccurrence } from '@/factory'
import { FieldOccurrence } from '@/routes/endpoints'

export default defineStore('fieldOccurrences', {
  state: () => ({
    fieldOccurrence: makeFieldOccurrence(),
    softValidations: {}
  }),

  actions: {
    async save() {
      const payload = {
        field_occurrence: this.fieldOccurrence
      }

      const request = this.fieldOccurrence.id
        ? FieldOccurrence.update(this.fieldOccurrence.id, payload)
        : FieldOccurrence.create(payload)

      request.then(({ body }) => {
        this.fieldOccurrence = body
      })

      return request
    }
  }
})
