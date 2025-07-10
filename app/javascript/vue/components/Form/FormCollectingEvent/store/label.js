import { defineStore } from 'pinia'
import { Label } from '@/routes/endpoints'

export default defineStore('collectingEvent:label', {
  state: () => ({
    label: {
      id: undefined,
      text: '',
      total: 1,
      isUnsaved: false
    }
  }),

  actions: {
    async load({ objectId, objectType }) {
      const request = Label.where({
        label_object_id: objectId,
        label_object_type: objectType
      })

      request.then(({ body }) => {
        const [label] = body

        if (label) {
          this.label.id = label.id
          this.label.text = label.text
          this.label.total = label.total
          this.label.isUnsaved = false
        }
      })

      return request
    },

    save({ objectId, objectType }) {
      const label = this.label

      if (!label.text.trim().length) {
        if (label.id) {
          Label.destroy(label.id).then((_) => {
            this.$reset()
          })
        }

        return Promise.resolve([])
      }

      const payload = {
        label: {
          label_object_id: objectId,
          label_object_type: objectType,
          total: label.total,
          text: label.text
        }
      }

      const request = label.id
        ? Label.update(label.id, payload)
        : Label.create(payload)

      request
        .then(({ body }) => {
          this.label.id = body.id
          this.label.isUnsaved = false
        })
        .catch(() => {})

      return request
    }
  }
})
