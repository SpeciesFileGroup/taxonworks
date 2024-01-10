import { IDENTIFIER_LOCAL_TRIP_CODE } from '@/constants/index.js'
import { defineStore } from 'pinia'
import makeCollectingEvent from '@/factory/CollectingEvent.js'
import makeIdentifier from '@/factory/Identifier.js'

export default defineStore('fieldOccurrences', {
  state: () => ({
    settings: {
      isLoading: false,
      isSaving: false,
      lastChange: 0,
      lastSave: 0
    },
    collectingEvent: makeCollectingEvent(),
    geographicArea: undefined,
    georeferences: [],
    tripCode: makeIdentifier(IDENTIFIER_LOCAL_TRIP_CODE, 'CollectingEvent'),
    softValidations: {},
    queueGeoreferences: [],
    unit: 'm',
    totalCO: 0
  })
})
