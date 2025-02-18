import { defineStore } from 'pinia'
import { Citation } from '@/routes/endpoints'
import { addToArray, removeFromArray, randomUUID } from '@/helpers'
import makeCitation from '@/factory/Citation.js'

export default defineStore('citations', {
  state: () => ({
    citations: [],
    citation: makeCitation()
  }),

  getters: {
    hasUnsaved(state) {
      return state.citations.some((c) => c.isUnsaved || c._destroy)
    }
  },

  actions: {
    load({ objectId, objectType }) {
      return Citation.where({
        citation_object_id: objectId,
        citation_object_type: objectType
      }).then(({ body }) => {
        this.citations = body.map((c) => ({
          ...c,
          uuid: randomUUID(),
          label: c.object_tag
        }))
      })
    },

    newCitation() {
      this.citation = makeCitation()
    },

    save({ objectId, objectType }) {
      this.citations.forEach((item) => {
        if (item._destroy) {
          this.remove(item)
        }
      })

      const citations = this.citations.filter((c) => c.isUnsaved)

      const requests = citations.map((citation) => {
        const payload = {
          citation: {
            ...citation,
            citation_object_id: objectId,
            citation_object_type: objectType
          }
        }

        const request = citation.id
          ? Citation.update(citation.id, payload)
          : Citation.create(payload)

        request
          .then(({ body }) => {
            const data = Object.assign(body, {
              uuid: citation.uuid,
              label: body.object_tag
            })

            addToArray(this.citations, data, { property: 'uuid' })
          })
          .catch({})

        return request
      })

      return Promise.all(requests)
    },

    remove(item) {
      if (item.id) {
        Citation.destroy(item.id).catch({})
      }

      removeFromArray(this.citations, item, { property: 'uuid' })
    },

    reset({ keepRecords }) {
      if (keepRecords) {
        this.citations = this.citations
          .filter((c) => !c._destroy)
          .map((item) => ({
            ...item,
            id: null,
            isUnsaved: true
          }))
      } else {
        this.$reset()
      }
    }
  }
})
