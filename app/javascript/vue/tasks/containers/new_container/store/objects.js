import { defineStore } from 'pinia'
import { removeFromArray } from '@/helpers'
import { compareObjects } from '../utils'

export const useObjectStore = defineStore('objects', {
  state: () => ({
    objects: []
  }),

  actions: {
    removeFromList(item) {
      removeFromArray(this.objects, item)
    },

    addObject(item) {
      if (!this.objects.some((obj) => compareObjects(item, obj))) {
        this.objects.push(item)
      }
    }
  }
})
