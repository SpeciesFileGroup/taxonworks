import { defineStore } from 'pinia'
import { makeFieldOccurrence } from '@/factory'
import { FieldOccurrence } from '@/routes/endpoints'
import useDeterminationStore from '../store/determinations.js'

export default defineStore('fieldOccurrences', {
  state: () => ({
    fieldOccurrence: makeFieldOccurrence(),
    softValidations: {}
  }),

  actions: {
    async load(id) {
      const request = FieldOccurrence.find(id)

      request
        .then(({ body }) => {
          this.fieldOccurrence = body
        })
        .catch(() => {})

      return request
    },

    async save() {
      const determinationStore = useDeterminationStore()
      const payload = {
        field_occurrence: {
          ...this.fieldOccurrence,
          taxon_determinations_attributes:
            determinationStore.determinations.filter((d) => d.isUnsaved)
        }
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
