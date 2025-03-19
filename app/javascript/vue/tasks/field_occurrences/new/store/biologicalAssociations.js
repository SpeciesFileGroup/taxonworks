import { defineStore } from 'pinia'
import { BiologicalAssociation } from '@/routes/endpoints'
import { addToArray, removeFromArray, randomUUID } from '@/helpers'
import makeCitation from '@/factory/Citation'

export default defineStore('biologicalAssociations', {
  state: () => ({
    biologicalAssociations: []
  }),

  getters: {
    hasUnsaved(state) {
      return state.biologicalAssociations.some((c) => c.isUnsaved)
    },

    bas(state) {
      return state.biologicalAssociations
    }
  },

  actions: {
    load({ objectId, objectType }) {
      return BiologicalAssociation.where({
        biological_association_subject_id: [objectId],
        biological_association_subject_type: [objectType],
        extend: ['subject', 'object', 'biological_relationship', 'citations']
      }).then(({ body }) => {
        this.biologicalAssociations = body.map((item) => {
          const citation = { ...item.citations[0], ...makeCitation() }

          citation.label = citation.object_label

          return {
            id: item.id,
            related: item.subject,
            relationship: item.biological_relationship,
            citation,
            uuid: randomUUID(),
            isUnsaved: false
          }
        })
      })
    },

    add(biologicalAssociation) {
      addToArray(
        this.biologicalAssociations,
        { ...biologicalAssociation, isUnsaved: true },
        {
          property: 'uuid',
          prepend: true
        }
      )
    },

    remove(biologicalAssociation) {
      if (biologicalAssociation.id) {
        BiologicalAssociation.destroy(biologicalAssociation.id)
          .then(() => {
            TW.workbench.alert.create(
              'Biological association was successfully destroyed.',
              'notice'
            )
          })
          .catch(() => {})
      }

      removeFromArray(this.biologicalAssociations, biologicalAssociation, {
        property: 'uuid'
      })
    },

    save({ objectId, objectType }) {
      const biologicalAssociations = this.biologicalAssociations.filter(
        (d) => d.isUnsaved
      )

      const requests = biologicalAssociations.map((ba) => {
        const payload = {
          biological_association: {
            biological_association_subject_id: objectId,
            biological_association_subject_type: objectType,
            biological_association_object_id: ba.related.id,
            biological_association_object_type: ba.related.base_class,
            biological_relationship_id: ba.relationship.id,
            citation_attribute: ba.citation
          }
        }

        const request = ba.id
          ? BiologicalAssociation.update(ba.id, payload)
          : BiologicalAssociation.create(payload)

        request.then(({ body }) => {
          Object.assign(ba, { isUnsaved: false, id: body.id })
        })

        return request
      })

      return Promise.all(requests)
    },

    reset({ keepRecords }) {
      if (keepRecords) {
        this.biologicalAssociations.forEach((item) => {
          Object.assign(item, {
            id: null,
            isUnsaved: true
          })
        })
      } else {
        this.$reset()
      }
    }
  }
})
