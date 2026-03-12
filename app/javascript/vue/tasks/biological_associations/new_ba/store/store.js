import { defineStore } from 'pinia'
import {
  AnatomicalPart,
  AssertedDistribution,
  BiologicalAssociation
} from '@/routes/endpoints'
import { BIOLOGICAL_ASSOCIATION } from '@/constants'
import { smartSelectorRefresh } from '@/helpers/smartSelector/index.js'
import { addToArray, removeFromArray, setParam } from '@/helpers'
import { RouteNames } from '@/routes/routes'
import { ANATOMICAL_PART } from '@/constants/modelTypes.js'
import makeCitation from '@/factory/Citation'

export function makeAnatomicalPart(data = {}) {
  return {
    id: data.id || null,
    name: data.name || '',
    uri: data.uri || '',
    uri_label: data.uri_label || '',
    is_material: data.is_material ?? undefined,
    preparation_type_id: data.preparation_type_id || undefined,
    object_tag: data.object_tag || null
  }
}

function makeBiologicalAssociation(data = {}) {
  return {
    id: data.id,
    isUnsaved: false
  }
}

function makeBiologicalAssociationItem(item) {
  return {
    id: item.id,
    global_id: item.global_id,
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

async function createAnatomicalPart(ap, originObject) {
  const { body } = await AnatomicalPart.create({
    anatomical_part: {
      name: ap.name,
      uri: ap.uri,
      uri_label: ap.uri_label,
      is_material: ap.is_material,
      preparation_type_id: ap.preparation_type_id,
      inbound_origin_relationship_attributes: {
        old_object_id: originObject.id,
        old_object_type: originObject.base_class
      }
    }
  })

  return body
}

function makeAssertedDistributionPayload({
  biologicalAssociationId,
  shape,
  citation
}) {
  return {
    asserted_distribution_object_type: BIOLOGICAL_ASSOCIATION,
    asserted_distribution_object_id: biologicalAssociationId,
    asserted_distribution_shape_type: shape.shapeType,
    asserted_distribution_shape_id: shape.id,
    citations_attributes: [
      {
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
      citation: false,
      relationship: false,
      object: false,
      subject: false,
      shape: false
    },

    biologicalAssociation: makeBiologicalAssociation(),
    biologicalAssociations: [],
    citation: makeCitation(),
    object: null,
    subject: null,
    relationship: null,
    shape: null,
    assertedDistribution: null,
    subjectAnatomicalPart: null,
    objectAnatomicalPart: null,
    isLoading: false,
    source: undefined
  }),

  getters: {
    isSaveAvailable(state) {
      return state.object && state.subject && state.relationship
    },

    shortCitation(state) {
      if (state.citation.citation_source_body) {
        return state.citation.citation_source_body
      }

      const { year, cached_author_string } = state.source || {}
      const citation = [cached_author_string, year].filter(Boolean).join(', ')

      return state.citation.pages
        ? `${citation}:${state.citation.pages}`
        : citation
    }
  },

  actions: {
    setBiologicalAssociation(ba) {
      this.biologicalAssociation = makeBiologicalAssociation(ba)
      this.subject = ba.subject
      this.object = ba.object
      this.relationship = ba.relationship
      this.citation = ba.citation
      this.subjectAnatomicalPart = null
      this.objectAnatomicalPart = null
      this.assertedDistribution = null
      this.shape = null

      this.loadAssertedDistribution(ba.id)

      setParam(
        RouteNames.NewBiologicalAssociationsII,
        'biological_association_id',
        ba.id
      )
    },

    toggleLock() {
      const lockAll = !Object.values(this.lock).every(Boolean)

      for (const key in this.lock) {
        this.lock[key] = lockAll
      }
    },

    loadBiologicalAsscoation(id) {
      this.isLoading = true

      BiologicalAssociation.find(id, { extend })
        .then(({ body }) => {
          const ba = makeBiologicalAssociationItem(body)

          this.setBiologicalAssociation(ba)
        })
        .catch(() => {})
        .finally(() => {
          this.isLoading = false
        })
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

      let resolvedSubject = this.subject
      let resolvedObject = this.object

      try {
        if (this.subjectAnatomicalPart) {
          if (this.subjectAnatomicalPart.id) {
            resolvedSubject = {
              id: this.subjectAnatomicalPart.id,
              base_class: ANATOMICAL_PART
            }
          } else {
            const ap = await createAnatomicalPart(
              this.subjectAnatomicalPart,
              this.subject
            )
            resolvedSubject = { id: ap.id, base_class: ANATOMICAL_PART }
          }
        }

        if (this.objectAnatomicalPart) {
          if (this.objectAnatomicalPart.id) {
            resolvedObject = {
              id: this.objectAnatomicalPart.id,
              base_class: ANATOMICAL_PART
            }
          } else {
            const ap = await createAnatomicalPart(
              this.objectAnatomicalPart,
              this.object
            )
            resolvedObject = { id: ap.id, base_class: ANATOMICAL_PART }
          }
        }
      } catch {}

      const payload = {
        biological_association: makeBiologicalAssociationPayload({
          object: resolvedObject,
          subject: resolvedSubject,
          relationship: this.relationship,
          citation: this.citation
        }),
        extend
      }

      if (!this.biologicalAssociation.id) {
        const { body } = await BiologicalAssociation.where({
          biological_relationship_id: this.relationship.id,
          biological_association_subject_id: resolvedSubject.id,
          biological_association_subject_type: resolvedSubject.base_class,
          biological_association_object_id: resolvedObject.id,
          biological_association_object_type: resolvedObject.base_class
        })

        if (body.length) {
          const [existingBA] = body

          this.biologicalAssociation.id = existingBA.id
        }
      }

      const request = this.biologicalAssociation.id
        ? BiologicalAssociation.update(this.biologicalAssociation.id, payload)
        : BiologicalAssociation.create(payload)

      request
        .then(async ({ body }) => {
          addToArray(
            this.biologicalAssociations,
            makeBiologicalAssociationItem(body),
            { prepend: true }
          )
          TW.workbench.alert.create(
            'Biological association was successfully saved.',
            'notice'
          )

          if (this.shape && this.citation.source_id) {
            await this.saveAssertedDistribution(body.id)
          }

          this.reset()
          smartSelectorRefresh()
        })
        .catch(() => {})
    },

    async saveAssertedDistribution(biologicalAssociationId) {
      const adPayload = makeAssertedDistributionPayload({
        biologicalAssociationId,
        shape: this.shape,
        citation: this.citation
      })

      try {
        let request

        if (this.assertedDistribution?.id) {
          adPayload.citations_attributes[0].id =
            this.assertedDistribution.citationId

          request = AssertedDistribution.update(this.assertedDistribution.id, {
            asserted_distribution: adPayload
          })
        } else {
          request = AssertedDistribution.create({
            asserted_distribution: adPayload
          })
        }

        await request
        TW.workbench.alert.create(
          'Asserted distribution was successfully saved.',
          'notice'
        )
      } catch {}
    },

    async loadAssertedDistribution(biologicalAssociationId) {
      try {
        const { body } = await AssertedDistribution.where({
          asserted_distribution_object_id: biologicalAssociationId,
          asserted_distribution_object_type: BIOLOGICAL_ASSOCIATION,
          extend: ['asserted_distribution_shape', 'citations']
        })

        if (body.length) {
          const ad = body[0]

          this.assertedDistribution = {
            id: ad.id,
            citationId: ad.citations?.[0]?.id
          }

          this.shape = {
            shapeType: ad.asserted_distribution_shape_type,
            ...ad.asserted_distribution_shape
          }
        }
      } catch {}
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
        this.source = undefined
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

      if (!this.lock.shape) {
        this.shape = null
        this.assertedDistribution = null
      }

      this.subjectAnatomicalPart = null
      this.objectAnatomicalPart = null

      setParam(
        RouteNames.NewBiologicalAssociationsII,
        'biological_association_id'
      )
    }
  }
})
