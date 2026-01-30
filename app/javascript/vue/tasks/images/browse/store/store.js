import { defineStore } from 'pinia'
import { Depiction, Image } from '@/routes/endpoints'

function makeImage(data) {
  return {
    id: data.id,
    globalId: data.global_id,
    imageUrl: data.original_png,
    label: data.object_label,
    pixelsToCm: data.pixels_to_centimeter,
    width: data.width,
    height: data.height
  }
}

export default defineStore('store', {
  state: () => ({
    image: null,
    isLoading: false,
    depictions: [],
    selected: [],
    currentPixelsToCm: null
  }),
  getters: {
    hasDepictions: (state) => state.depictions.length > 0,

    depictionObjects: (state) => {
      return state.depictions.map((depiction) => depiction.depiction_object)
    },

    svgClips: (state) => state.selected.map((d) => d.svg_clip).filter(Boolean)
  },
  actions: {
    async load(imageId) {
      this.isLoading = true

      return Image.find(imageId)
        .then(({ body }) => {
          this.image = makeImage(body)
          this.currentPixelsToCm = body.pixels_to_centimeter
        })
        .catch(() => {
          TW.workbench.alert.create('Image not found', 'error')
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
