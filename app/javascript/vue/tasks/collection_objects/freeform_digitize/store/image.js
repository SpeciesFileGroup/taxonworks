import { defineStore } from 'pinia'
import { Image } from '@/routes/endpoints'

export default defineStore('image', {
  state: () => ({
    image: null
  }),

  actions: {
    async loadImage(id) {
      return Image.find(id).then((response) => {
        this.image = response.body
      })
    }
  }
})
