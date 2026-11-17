import { BiologicalAssociation } from '@/routes/endpoints'
import { defineStore } from 'pinia'

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

  actions: {
    async load({ objectId, objectType }) {
      const requests = [
        BiologicalAssociation.where({
          biological_association_subject_id: [objectId],
          biological_association_subject_type: [objectType]
        }),
        BiologicalAssociation.where({
          biological_association_subject_type: ['AnatomicalPart'],
          anatomical_part_query: { field_occurrence_id: objectId }
        })
      ]

      return Promise.all(requests)
        .then(([{ body: own }, { body: parts }]) => {
          this.biologicalAssociations = [
            ...own,
            ...parts.filter((item) =>
              originatesFrom(item.subject_anatomical_part, {
                objectId,
                objectType
              })
            )
          ]
        })
        .catch(() => {})
    }
  }
})
