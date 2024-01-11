import { defineStore } from 'pinia'
import { makeFieldOccurrence } from '@/factory'

export default defineStore('fieldOccurrences', {
  state: () => ({
    fieldOccurrence: makeFieldOccurrence(),
    softValidations: {}
  })
})
