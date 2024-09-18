import { defineStore } from 'pinia'
import { AssertedDistribution, Confidence } from '@/routes/endpoints'
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

const extend = ['citations', 'geographic_area', 'otu', 'source']

export const useStore = defineStore('NewAssertedDistribution', {
  state: () => ({
    lock: {
      source: false,
      otu: false,
      geographicArea: false,
      confidences: false
    },

    assertedDistribution: makeAssertedDistribution(),
    assertedDistributions: [],
    citation: makeCitation(),
    otu: null,
    geographicArea: null,
    confidences: [],
    isLoading: false,
    autosave: true
  }),

  getters: {
    isSaveAvailable(state) {
      return state.otu && state.geographicArea && state.citation
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
        otu: this.otu,
        geographicArea: this.geographicArea,
        citation: this.citation
      })

      console.log(assertedDistribution)

      if (assertedDistribution.id) {
        this.saveRecord(assertedDistribution)
      } else {
        try {
          const { body } = await AssertedDistribution.where({
            otu_id: assertedDistribution.otu_id,
            geographic_area_id: assertedDistribution.geographic_area_id,
            extend
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

      if (!this.lock.geographicArea) {
        this.geographicArea = null
      }

      if (!this.lock.otu) {
        this.otu = null
      }

      this.confidences = this.lock.confidences
        ? this.confidences.map(({ id, ...rest }) => rest)
        : []
    }
  }
})
