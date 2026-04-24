import { defineStore } from 'pinia'
import { AssertedDistribution, Citation, Confidence } from '@/routes/endpoints'
import { smartSelectorRefresh } from '@/helpers/smartSelector/index.js'
import { addToArray, removeFromArray, setParam } from '@/helpers'
import { makeAssertedDistributionPayload } from '../adapters'
import { ASSERTED_DISTRIBUTION } from '@/constants'

import makeCitation from '@/factory/Citation'
import { RouteNames } from '@/routes/routes'

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
    isSaving: false,
    autosave: false
  }),

  getters: {
    isSaveAvailable(state) {
      return state.object && state.shape && state.citation
    }
  },

  actions: {
    async load(id) {
      const promises = []

      this.isLoading = true
      this.assertedDistribution = makeAssertedDistribution()
      this.confidences = []
      this.autosave = false

      promises.push(
        AssertedDistribution.find(id, { extend }).then(({ body }) => {
          const [citation] = body.citations

          this.assertedDistribution.id = body.id
          this.shape = {
            shapeType: body.asserted_distribution_shape_type,
            ...body.asserted_distribution_shape
          }
          this.object = {
            objectType: body.asserted_distribution_object_type,
            ...body.asserted_distribution_object
          }
          this.isAbsent = body.is_absent

          this.citation = {
            id: citation.id,
            source_id: citation.source_id,
            is_original: citation.is_original,
            pages: citation.pages
          }
        })
      )

      promises.push(
        Confidence.where({
          confidence_object_id: id,
          confidence_object_type: ASSERTED_DISTRIBUTION
        }).then(({ body }) => {
          this.confidences = body.map((c) => ({
            ...c,
            label: c.confidence_level.object_tag
          }))
        })
      )

      Promise.all(promises)
        .catch(() => {})
        .finally(() => (this.isLoading = false))
    },
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

      this.isSaving = true

      const request = assertedDistribution.id
        ? AssertedDistribution.update(assertedDistribution.id, payload)
        : AssertedDistribution.create(payload)

      request
        .then(async ({ body }) => {
          addToArray(this.assertedDistributions, body, { prepend: true })

          await this.saveConfidences(body)
          TW.workbench.alert.create(
            'Asserted distribution was successfully saved.',
            'notice'
          )
          this.reset()
          smartSelectorRefresh()
        })
        .catch(() => {})
        .finally(() => {
          this.isSaving = false
        })
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

    removeConfidence(index) {
      const confidenceId = this.confidences[index]?.id

      if (
        !confidenceId ||
        window.confirm('Are you sure you want to delete this item?')
      ) {
        if (confidenceId) {
          Confidence.destroy(confidenceId)
        }

        this.confidences.splice(index, 1)
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

    async saveConfidences(record) {
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

      return await Promise.all(promises)
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

      setParam(RouteNames.NewAssertedDistribution, 'asserted_distribution_id')
    }
  }
})
