import { defineStore } from 'pinia'
import { Depiction, Image } from '@/routes/endpoints'
import { getHexColorFromString } from '@/tasks/biological_associations/biological_associations_graph/utils'

function makeImage(data) {
  return {
    id: data.id,
    globalId: data.global_id,
    imageUrl: data.original_png,
    label: data.object_label,
    pixelsToCm: data.pixels_to_centimeter || 0,
    width: data.width,
    height: data.height
  }
}

function createGroupElement(text) {
  const el = document.createElementNS('http://www.w3.org/2000/svg', 'g')
  el.innerHTML = text

  return el.firstChild
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

    layers: (state) => {
      return state.selected
        .map((d) => {
          const el = createGroupElement(d.svg_clip)
          const attributes = {
            fill: getHexColorFromString(String(d.depiction_object_id)),
            'fill-opacity': 0.25,
            'stroke-width': 1 * window.devicePixelRatio
          }

          const shapes = [...el.children].map((child) => {
            const shape = child.firstChild

            Object.entries(attributes).forEach(([attribute, value]) => {
              shape.setAttribute(attribute, value)
            })

            return child.innerHTML
          })

          return shapes
        })
        .flat()
    }
  },
  actions: {
    async load(imageId) {
      this.isLoading = true

      return Image.find(imageId)
        .then(({ body }) => {
          this.image = makeImage(body)
          this.currentPixelsToCm = this.image.pixelsToCm
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
