import { Conveyance, Sound } from '@/routes/endpoints'
import { defineStore } from 'pinia'

export default defineStore('store', {
  state: () => ({
    sound: null,
    citations: [],
    conveyances: []
  }),
  actions: {
    loadSound(soundId) {
      Sound.find(soundId).then(({ body }) => {
        this.sound = body
      })
    },

    loadConveyances(soundId) {
      Conveyance.where({ sound_id: soundId }).then(({ body }) => {
        this.conveyances.value = body
      })
    }
  }
})
