import { defineStore } from 'pinia'
import { IDENTIFIER_LOCAL_TRIP_CODE } from '@/constants/index.js'
import { makeFieldOccurrence } from '@/factory'
import makeCollectingEvent from '@/factory/CollectingEvent.js'
import makeIdentifier from '@/factory/Identifier.js'

export default defineStore('fieldOccurrences', {
  state: () => ({
    collectingEvent: makeCollectingEvent(),
    fieldOccurrence: makeFieldOccurrence(),
    geographicArea: undefined,
    georeferences: [],
    tripCode: makeIdentifier(IDENTIFIER_LOCAL_TRIP_CODE, 'CollectingEvent'),
    softValidations: {},
    queueGeoreferences: [],
    unit: 'm',
    totalCO: 0
  })
})
