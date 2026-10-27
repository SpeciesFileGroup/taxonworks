import { defineStore } from 'pinia'
import { BiologicalAssociation } from '@/routes/endpoints'
import { COLLECTION_OBJECT, FIELD_OCCURRENCE } from '@/constants'
import { addToArray, removeFromArray, randomUUID } from '@/helpers'

const extend = ['subject', 'object', 'biological_relationship', 'citations']

const ORIGIN_QUERY_PARAM = {
  [COLLECTION_OBJECT]: 'collection_object_id',
  [FIELD_OCCURRENCE]: 'field_occurrence_id'
}

function makeCitation(data) {
  return {
    uuid: randomUUID(),
    source_id: data.source_id,
    label: data.citation_source_body,
    pages: data.pages,
    isUnsaved: false
  }
}

function makeItem(item, anatomicalPart = null) {
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
    anatomicalPart,
    isUnsaved: false
  }
}

function originatesFrom(anatomicalPart, { objectId, objectType }) {
  return (
    anatomicalPart?.origin_object_type === objectType &&
    Number(anatomicalPart?.origin_object_id) === Number(objectId)
  )
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
      const originParam = ORIGIN_QUERY_PARAM[objectType]

      const requests = [
        BiologicalAssociation.where({
          biological_association_subject_id: [objectId],
          biological_association_subject_type: [objectType],
          extend
        }),
        originParam
          ? BiologicalAssociation.where({
              biological_association_subject_type: ['AnatomicalPart'],
              anatomical_part_query: { [originParam]: objectId },
              extend
            })
          : Promise.resolve({ body: [] })
      ]

      return Promise.all(requests).then(([{ body: own }, { body: parts }]) => {
        this.biologicalAssociations = [
          ...own.map((item) => makeItem(item)),
          ...parts
            .filter((item) =>
              originatesFrom(item.subject_anatomical_part, {
                objectId,
                objectType
              })
            )
            .map((item) => makeItem(item, item.subject_anatomical_part))
        ]
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
            globalId: body.global_id
          })
        })

        return request
      })

      return Promise.all(requests)
    },

    reset({ keepRecords }) {
      if (keepRecords) {
        this.biologicalAssociations = this.biologicalAssociations.filter(
          (item) => !item.anatomicalPart
        )

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
