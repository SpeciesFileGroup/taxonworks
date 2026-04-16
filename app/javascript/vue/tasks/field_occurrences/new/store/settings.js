import { defineStore } from 'pinia'

function hasFalse(o) {
  return Object.values(o).some((value) => {
    if (typeof value === 'object' && value !== null) {
      return hasFalse(value)
    }
    return value === false
  })
}

export default defineStore('settings', {
  state: () => ({
    isLoading: false,
    isSaving: false,
    sortable: false,
    locked: {
      biocurations: false,
      citations: false,
      collectingEvent: false,
      taxonDeterminations: false,
      namespace: false,
      biologicalAssociation: {
        list: false,
        related: false,
        relationship: false
      }
    }
  }),

  actions: {
    toggleLock() {
      const hasFalse = (o) =>
        Object.values(o).some((value) => {
          if (typeof value === 'object' && value !== null) {
            return hasFalse(value)
          }
          return value === false
        })

      const newValue = hasFalse(this.locked)

      const applyToggle = (o) => {
        Object.keys(o).forEach((key) => {
          if (typeof o[key] === 'object' && o[key] !== null) {
            applyToggle(o[key])
          } else if (typeof o[key] === 'boolean') {
            o[key] = newValue
          }
        })
      }

      applyToggle(this.locked)
    }
  }
})
