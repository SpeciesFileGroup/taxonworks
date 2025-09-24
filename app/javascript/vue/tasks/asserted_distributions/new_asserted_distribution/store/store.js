import { defineStore } from 'pinia'
import { AssertedDistribution, Citation, Confidence } from '@/routes/endpoints'
import { smartSelectorRefresh } from '@/helpers/smartSelector/index.js'
import { addToArray, removeFromArray } from '@/helpers'
import { makeAssertedDistributionPayload } from '../adapters'
import { ASSERTED_DISTRIBUTION } from '@/constants'
import makeCitation from '@/factory/Citation'

function makeAssertedDistribution(data = {}) {
  return {
    id: data.id,
    isAbsent: data.is_absent,
    isUnsaved: false
  }
}

const extend = [
  'citations',
  'asserted_distribution_shape',
  'asserted_distribution_object',
  'source'
]

export const useStore = defineStore('NewAssertedDistribution', {
  state: () => ({
    lock: {
      source: false,
      object: false,
      shape: false,
      confidences: false
    },

    assertedDistribution: makeAssertedDistribution(),
    assertedDistributions: [],
    citation: makeCitation(),
    object: null,
    shape: null,
    confidences: [],
    isLoading: false,
    autosave: true
  }),

  getters: {
    isSaveAvailable(state) {
      return state.object && state.shape && state.citation
    }
  },

  actions: {
    async loadRecentAssertedDistributions() {
      try {
        const { body } = await AssertedDistribution.where({
          recent: true,
          per: 15,
          extend
        })
        this.assertedDistributions = body
      } catch {}

      this.isLoading = false
    },

    saveRecord(assertedDistribution) {
      const payload = {
        asserted_distribution: assertedDistribution,
        extend
      }

      const request = assertedDistribution.id
        ? AssertedDistribution.update(assertedDistribution.id, payload)
        : AssertedDistribution.create(payload)

      request
        .then(({ body }) => {
          addToArray(this.assertedDistributions, body, { prepend: true })
          TW.workbench.alert.create(
            'Asserted distribution was successfully saved.',
            'notice'
          )
          this.saveConfidences(body)
          this.reset()
          smartSelectorRefresh()
        })
        .catch(() => {})
    },

    async saveAssertedDistribution() {
      if (!this.isSaveAvailable) return

      const assertedDistribution = makeAssertedDistributionPayload({
        ad: this.assertedDistribution,
        object: this.object,
        shape: this.shape,
        citation: this.citation
      })

      if (assertedDistribution.id) {
        this.saveRecord(assertedDistribution)
      } else {
        try {
          const { body } = await AssertedDistribution.where({
            asserted_distribution_object_id:
              assertedDistribution.asserted_distribution_object_id,
            asserted_distribution_object_type:
              assertedDistribution.asserted_distribution_object_type,
            geo_shape_type:
              assertedDistribution.asserted_distribution_shape_type,
            geo_shape_id: assertedDistribution.asserted_distribution_shape_id,
            extend
            // geo_mode: nil // i.e. Exact
          })

          const record = body.find(
            (item) => !!item.is_absent === !!this.assertedDistribution.isAbsent
          )

          if (record) {
            assertedDistribution.id = record.id
          }

          this.saveRecord(assertedDistribution)
        } catch {}
      }
    },

    removeAssertedDistribution(item) {
      AssertedDistribution.destroy(item.id).then(() => {
        removeFromArray(this.assertedDistributions, item)

        TW.workbench.alert.create(
          'Asserted distribution was successfully destroyed.',
          'notice'
        )
      })
    },

    removeAssertedDistributionCitation(citation) {
      const objectId = citation.citation_object_id
      const ad = this.assertedDistributions.find((ad) => ad.id == objectId)

      Citation.destroy(citation.id)
        .then(() => {
          removeFromArray(ad.citations, citation)
        })
        .catch(() => {})
    },

    saveConfidences(record) {
      this.isLoading = true

      const unsaved = this.confidences.filter((item) => !item.id)
      const promises = unsaved.map((item) =>
        Confidence.create({
          confidence: {
            confidence_level_id: item.controlledVocabularyId,
            confidence_object_id: record.id,
            confidence_object_type: ASSERTED_DISTRIBUTION
          }
        })
          .then(({ body }) => {
            item.id = body.id
          })
          .catch(() => {})
      )

      Promise.all(promises).then(() => {
        this.isLoading = false
      })
    },

    reset() {
      this.assertedDistribution = makeAssertedDistribution()

      if (!this.lock.citation) {
        this.citation = makeCitation()
      } else {
        this.citation.id = null
      }

      if (!this.lock.shape) {
        this.shape = null
      }

      if (!this.lock.object) {
        this.object = null
      }

      this.confidences = this.lock.confidences
        ? this.confidences.map(({ id, ...rest }) => rest)
        : []
    }
  }
})
