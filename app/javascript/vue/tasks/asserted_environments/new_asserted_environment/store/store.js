// Written with CLAUDE code
import { defineStore } from 'pinia'
import { AssertedEnvironment, Citation } from '@/routes/endpoints'
import { smartSelectorRefresh } from '@/helpers/smartSelector/index.js'
import { addToArray, removeFromArray } from '@/helpers'
import { makeAssertedEnvironmentPayload } from '../adapters'
import { ASSERTED_ENVIRONMENT } from '@/constants'

import makeCitation from '@/factory/Citation'

const extend = ['citations']

function isSameCitation(a, b) {
  return a.source_id === b.source_id && (a.pages || null) === (b.pages || null)
}

export const useStore = defineStore('NewAssertedEnvironment', {
  state: () => ({
    lock: {
      source: false,
      object: false,
      environment: false
    },

    assertedEnvironments: [],
    citation: makeCitation(),
    object: null,
    environment: null,
    isLoading: false,
    isSaving: false,
    autosave: false
  }),

  getters: {
    isSaveAvailable(state) {
      return !!(state.object?.id && state.environment?.uri)
    }
  },

  actions: {
    async loadRecentAssertedEnvironments() {
      this.isLoading = true

      try {
        const { body } = await AssertedEnvironment.where({
          recent: true,
          per: 15,
          extend
        })
        this.assertedEnvironments = body
      } catch {}

      this.isLoading = false
    },

    // AssertedEnvironments can't be updated, only created. When the
    // (object, uri) pair already exists, the citation (if any) is added to
    // the existing record instead.
    async saveAssertedEnvironment() {
      if (!this.isSaveAvailable || this.isSaving) return

      const payload = makeAssertedEnvironmentPayload({
        object: this.object,
        environment: this.environment,
        citation: this.citation
      })

      this.isSaving = true

      try {
        const { body } = await AssertedEnvironment.where({
          asserted_environment_object_id: payload.asserted_environment_object_id,
          asserted_environment_object_type:
            payload.asserted_environment_object_type,
          uri: payload.uri,
          uri_exact: true,
          extend
        })

        const [existing] = body

        if (existing) {
          await this.addCitationToExisting(existing)
        } else {
          await this.createRecord(payload)
        }
      } catch {}

      this.isSaving = false
    },

    async createRecord(payload) {
      const { body } = await AssertedEnvironment.create({
        asserted_environment: payload,
        extend
      })

      addToArray(this.assertedEnvironments, body, { prepend: true })
      TW.workbench.alert.create(
        'Asserted environment was successfully saved.',
        'notice'
      )
      this.reset()
      smartSelectorRefresh()
    },

    async addCitationToExisting(record) {
      if (!this.citation.source_id) {
        TW.workbench.alert.create(
          'This asserted environment already exists.',
          'notice'
        )
        return
      }

      if ((record.citations || []).some((c) => isSameCitation(c, this.citation))) {
        TW.workbench.alert.create(
          'This asserted environment already exists with this citation.',
          'notice'
        )
        return
      }

      await Citation.create({
        citation: {
          citation_object_id: record.id,
          citation_object_type: ASSERTED_ENVIRONMENT,
          source_id: this.citation.source_id,
          pages: this.citation.pages,
          is_original: this.citation.is_original
        }
      })

      const { body } = await AssertedEnvironment.find(record.id, { extend })

      removeFromArray(this.assertedEnvironments, body)
      addToArray(this.assertedEnvironments, body, { prepend: true })
      TW.workbench.alert.create(
        'Asserted environment already existed, citation was added.',
        'notice'
      )
      this.reset()
      smartSelectorRefresh()
    },

    removeAssertedEnvironmentCitation(citation) {
      const record = this.assertedEnvironments.find(
        (item) => item.id === citation.citation_object_id
      )

      Citation.destroy(citation.id)
        .then(() => {
          removeFromArray(record.citations, citation)
        })
        .catch(() => {})
    },

    reset() {
      if (!this.lock.source) {
        this.citation = makeCitation()
      } else {
        this.citation.id = null
      }

      if (!this.lock.object) {
        this.object = null
      }

      if (!this.lock.environment) {
        this.environment = null
      }
    }
  }
})
