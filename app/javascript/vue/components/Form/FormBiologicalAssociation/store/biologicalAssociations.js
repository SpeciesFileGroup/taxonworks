import { defineStore } from 'pinia'
import { BiologicalAssociation } from '@/routes/endpoints'
import { addToArray, removeFromArray, randomUUID } from '@/helpers'

const extend = ['subject', 'object', 'biological_relationship', 'citations']

function makeCitation(data) {
  return {
    uuid: randomUUID(),
    source_id: data.source_id,
    label: data.object_label,
    pages: data.pages,
    isUnsaved: false
  }
}

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
        extend
      }).then(({ body }) => {
        this.biologicalAssociations = body.map((item) => {
          const citation = makeCitation(item.citations[0] || {})

          return {
            id: item.id,
            uuid: randomUUID(),
            globalId: item.global_id,
            related: item.object,
            relationship: {
              id: item.biological_relationship_id,
              ...item.biological_relationship
            },
            citation,
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
            citations_attributes: ba.citation.source_id
              ? [ba.citation]
              : undefined
          }
        }

        const request = ba.id
          ? BiologicalAssociation.update(ba.id, payload)
          : BiologicalAssociation.create(payload)

        request.then(({ body }) => {
          Object.assign(ba, {
            isUnsaved: false,
            id: body.id,
            globalId: item.global_id
          })
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
