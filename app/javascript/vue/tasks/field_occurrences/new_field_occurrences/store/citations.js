import { defineStore } from 'pinia'
import { Citation } from '@/routes/endpoints'
import makeCitation from '@/factory/Citation.js'

export default defineStore('citations', {
  state: () => ({
    citations: [],
    citation: makeCitation(),
  }),

  getters: {
    hasUnsaved(state) {
      return state.citations.some(c => c.isUnsaved)
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
    }
  }
})
