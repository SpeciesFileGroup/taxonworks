import { defineStore } from 'pinia'
import { Citation } from '@/routes/endpoints'
import { addToArray } from '@/helpers'
import makeCitation from '@/factory/Citation.js'

export default defineStore('citations', {
  state: () => ({
    citations: [],
    citation: makeCitation()
  }),

  getters: {
    hasUnsaved(state) {
      return state.citations.some((c) => c.isUnsaved)
    }
  },

  actions: {
    loadCitations({ id, type }) {
      Citation.where({
        citation_object_id: id,
        citation_object_type: type
      })
    },

    newCitation() {
      this.citation = makeCitation()
    },

    save({ objectId, objectType }) {
      const citations = this.citations.filter((d) => d.isUnsaved)

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

        request.then(({ body }) => {
          body.uuid = citation.uuid
          addToArray(this.citations, body, { property: 'uuid' })
        })

        return request
      })

      return Promise.all(requests)
    }
  }
})
