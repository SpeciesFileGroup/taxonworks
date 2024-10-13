import { defineStore } from 'pinia'
import { BiologicalAssociation } from '@/routes/endpoints'
import { smartSelectorRefresh } from '@/helpers/smartSelector/index.js'
import { addToArray, removeFromArray } from '@/helpers'
import makeCitation from '@/factory/Citation'

function makeBiologicalAssociation(data = {}) {
  return {
    id: data.id,
    isUnsaved: false
  }
}

function makeBiologicalAssociationItem(item) {
  return {
    id: item.id,
    object_tag: item.object_tag,
    object: {
      id: item.biological_association_object_id,
      base_class: item.biological_association_object_type,
      object_tag: item.object.object_tag
    },
    subject: {
      id: item.biological_association_subject_id,
      base_class: item.biological_association_subject_type,
      object_tag: item.subject.object_tag
    },
    relationship: {
      id: item.biological_relationship_id,
      object_tag: item.biological_relationship.object_tag
    },
    citation: item.citations?.[0] || makeCitation()
  }
}

function makeBiologicalAssociationPayload({
  object,
  subject,
  relationship,
  citation
}) {
  return {
    biological_relationship_id: relationship.id,
    biological_association_subject_id: subject.id,
    biological_association_subject_type: subject.base_class,
    biological_association_object_id: object.id,
    biological_association_object_type: object.base_class,
    citations_attributes: [
      {
        id: citation.id,
        source_id: citation.source_id,
        is_original: citation.is_original,
        pages: citation.pages
      }
    ]
  }
}

const extend = ['subject', 'object', 'biological_relationship', 'citations']

export const useStore = defineStore('NewBiologicalAssociation', {
  state: () => ({
    lock: {
      source: false,
      relationship: false,
      object: false,
      subject: false
    },

    biologicalAssociation: makeBiologicalAssociation(),
    biologicalAssociations: [],
    citation: makeCitation(),
    object: null,
    subject: null,
    relationship: null,
    isLoading: false
  }),

  getters: {
    isSaveAvailable(state) {
      return (
        state.object &&
        state.subject &&
        state.relationship &&
        state.citation.source_id
      )
    }
  },

  actions: {
    setBiologicalAssociation(ad) {
      this.biologicalAssociation = makeBiologicalAssociation(ad)
      this.object = ad.object
      this.subject = ad.subject
      this.relationship = ad.relationship
      this.citation = ad.citation
    },

    async loadRecentBiologicalAssociations() {
      BiologicalAssociation.where({
        recent: true,
        per: 15,
        extend
      })
        .then(({ body }) => {
          this.biologicalAssociations = body.map(makeBiologicalAssociationItem)
        })
        .finally(() => {
          this.isLoading = false
        })
    },

    async saveBiologicalAssociation() {
      if (!this.isSaveAvailable) return

      const payload = {
        biological_association: makeBiologicalAssociationPayload({
          object: this.object,
          subject: this.subject,
          relationship: this.relationship,
          citation: this.citation
        }),
        extend
      }

      const request = this.biologicalAssociation.id
        ? BiologicalAssociation.update(this.biologicalAssociation.id, payload)
        : BiologicalAssociation.create(payload)

      request
        .then(({ body }) => {
          addToArray(
            this.biologicalAssociations,
            makeBiologicalAssociationItem(body),
            { prepend: true }
          )
          TW.workbench.alert.create(
            'Biological association was successfully saved.',
            'notice'
          )
          this.reset()
          smartSelectorRefresh()
        })
        .catch(() => {})
    },

    removeBiologicalAssociation(item) {
      BiologicalAssociation.destroy(item.id).then(() => {
        removeFromArray(this.biologicalAssociations, item)

        TW.workbench.alert.create(
          'Biological association was successfully destroyed.',
          'notice'
        )
      })
    },

    reset() {
      this.biologicalAssociation = makeBiologicalAssociation()

      if (!this.lock.citation) {
        this.citation = makeCitation()
      } else {
        this.citation.id = null
      }

      if (!this.lock.object) {
        this.object = null
      }

      if (!this.lock.subject) {
        this.subject = null
      }

      if (!this.lock.relationship) {
        this.relationship = null
      }
    }
  }
})
