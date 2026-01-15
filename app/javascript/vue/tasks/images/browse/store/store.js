import { defineStore } from 'pinia'
import { Depiction, Image } from '@/routes/endpoints'

function makeImage(data) {
  return {
    id: data.id,
    globalId: data.global_id,
    imageUrl: data.original_png,
    pixelsToCm: data.pixels_to_centimeter,
    width: data.width,
    height: data.height
  }
}

export default defineStore('store', {
  state: () => ({
    image: null,
    isLoading: false,
    depictions: []
  }),
  getters: {
    hasDepictions: (state) => state.depictions.length > 0,

    depictionObjects: (state) => {
      return state.depictions.map((depiction) => depiction.depiction_object)
    }
  },
  actions: {
    async load(imageId) {
      this.isLoading = true

      return Image.find(imageId)
        .then(({ body }) => {
          this.image = makeImage(body)
        })
        .finally(() => {
          this.isLoading = false
        })
    },

    async loadDepictions(imageId) {
      return Depiction.where({
        image_id: imageId,
        extend: ['depiction_object']
      }).then(({ body }) => {
        this.depictions = body
      })
    }
  }
})
