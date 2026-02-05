import { defineStore } from 'pinia'

export const useOtuStore = defineStore('browse-otu', {
  state: () => ({
    otu: undefined,
    taxonName: undefined,
    coordinateOtus: []
  })
})
