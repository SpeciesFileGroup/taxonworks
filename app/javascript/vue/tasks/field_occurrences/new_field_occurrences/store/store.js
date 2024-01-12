import { defineStore } from 'pinia'
import { makeFieldOccurrence } from '@/factory'
import makeIdentifier from '@/factory/Identifier.js'

export default defineStore('fieldOccurrences', {
  state: () => ({
    fieldOccurrence: makeFieldOccurrence(),
    identifier: makeIdentifier(),
    softValidations: {}
  })
})
