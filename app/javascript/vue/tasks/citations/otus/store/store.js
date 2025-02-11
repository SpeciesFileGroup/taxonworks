import { OTU } from '@/constants'
import { defineStore } from 'pinia'
import { Citation, CitationTopic } from '@/routes/endpoints'
import { addToArray, removeFromArray } from '@/helpers'

const extend = ['citation_object', 'citation_topics', 'source']

export default defineStore('citeOtu', {
  state: () => ({
    selected: {
      otu: null,
      source: null,
      citation: null,
      citationTopics: []
    },
    topics: [],
    citations: [],
    sourceCitations: [],
    otuCitations: [],
    isLoading: false
  }),

  actions: {
    createTopicCitation({ citationId, topicId }) {
      const payload = {
        citation_topic: {
          topic_id: topicId,
          citation_id: citationId
        }
      }

      CitationTopic.create(payload).then(({ body }) => {
        addToArray(this.selected.citationTopics, body)
      })
    },

    destroyCurrentCitation() {
      Citation.destroy(this.selected.citation.id)
        .then(() => {
          this.selected.citation = null
          this.selected.citationTopics = []
          this.selected.otu = null
          this.selected.source = null
          this.sourceCitations = []
          this.otuCitations = []
          TW.workbench.alert.create('Citation was successfully destroyed.')
        })
        .catch(() => {})
    },

    destroyTopic(topic) {
      CitationTopic.destroy(topic.id).then(() => {
        removeFromArray(this.selected.citationTopics, topic)
      })
    },

    loadSourceCitations({ sourceId }) {
      Citation.where({
        source_id: sourceId,
        citation_object_type: OTU,
        extend
      }).then(({ body }) => {
        this.sourceCitations = body
      })
    },

    loadOtuCitations({ otuId }) {
      Citation.where({
        citation_object_type: OTU,
        citation_object_id: otuId,
        extend
      }).then(({ body }) => {
        this.otuCitations = body
      })
    },

    loadCitations({ otuId, sourceId }) {
      this.isLoading = true

      Citation.where({
        citation_object_type: OTU,
        citation_object_id: otuId,
        extend
      })
        .then(({ body }) => {
          const [citation] = body

          if (citation) {
            this.selected.citation = citation
            this.selected.citationTopics = citation.citation_topics
            this.isLoading = false
          } else {
            const payload = {
              citation: {
                citation_object_type: OTU,
                citation_object_id: otuId,
                source_id: sourceId
              },
              extend
            }

            Citation.create(payload)
              .then(({ body }) => {
                addToArray(this.citations, body)
                addToArray(this.sourceCitations, body)
                addToArray(this.otuCitations, body)
                this.selected.citation = body
                this.selected.citationTopics = body.citation_topics
                TW.workbench.alert.create('Citation was successfully created.')
              })
              .catch(() => {})
              .finally(() => {
                this.isLoading = false
              })
          }
        })
        .catch(() => {
          this.isLoading = false
        })
    }
  }
})
