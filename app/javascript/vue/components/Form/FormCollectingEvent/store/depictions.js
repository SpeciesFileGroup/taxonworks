import { defineStore } from 'pinia'
import { Depiction } from '@/routes/endpoints'
import { addToArray, removeFromArray, randomUUID } from '@/helpers'

function makeDepiction(d) {
  return {
    id: d.id,
    uuid: randomUUID(),
    global_id: d.global_id,
    imageId: d.image_id,
    image: d.image,
    caption: d.caption,
    figure_label: d.figure_label,
    isUnsaved: false
  }
}

export default defineStore('collectingEventForm:depictions', {
  state: () => ({
    depictions: []
  }),

  getters: {
    hasUnsaved(state) {
      return state.depictions.some((d) => d.isUnsaved)
    },

    getDepictionByImageId(state) {
      return (id) => state.depictions.find((d) => d.imageId === id)
    }
  },

  actions: {
    async load({ objectId, objectType }) {
      const request = Depiction.where({
        depiction_object_id: objectId,
        depiction_object_type: objectType
      })

      request.then(({ body }) => {
        this.depictions = body.map(makeDepiction)
      })

      return request
    },

    addImage(image) {
      this.depictions.push({
        id: null,
        uuid: randomUUID(),
        imageId: image.id,
        image,
        isUnsaved: true
      })
    },

    reset() {
      this.$reset()
    },

    remove(depiction) {
      if (depiction.id) {
        Depiction.destroy(depiction.id).then(() => {
          TW.workbench.alert.create(
            'Depiction was successfully deleted.',
            'notice'
          )
        })
      }

      removeFromArray(this.depictions, depiction)
    },

    save({ objectId, objectType }) {
      const depictions = this.depictions.filter((d) => d.isUnsaved)
      const requests = depictions.map((d) => {
        const payload = {
          depiction: {
            image_id: d.imageId,
            depiction_object_id: objectId,
            depiction_object_type: objectType
          }
        }

        const request = d.id
          ? Depiction.update(d.id, payload)
          : Depiction.create(payload)

        request
          .then(({ body }) => {
            Object.assign(d, makeDepiction(body), {
              isUnsaved: false
            })
          })
          .catch(() => {})

        return request
      })

      return Promise.all(requests)
    }
  }
})
