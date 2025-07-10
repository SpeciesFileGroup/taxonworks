import {
  BiocurationClassification,
  ControlledVocabularyTerm,
  Tag
} from '@/routes/endpoints'
import { BIOCURATION_GROUP } from '@/constants/index.js'
import { defineStore } from 'pinia'

async function makeGroup(groups, biocurations) {
  const newGroups = {}

  for (const groupId in groups) {
    await Tag.where({ keyword_id: groupId }).then(({ body }) => {
      body.forEach((item) => {
        biocurations.forEach((klass) => {
          if (klass.biocuration_class_id === item.tag_object_id) {
            if (groupId in newGroups) {
              newGroups[groupId].items.push(klass)
            } else {
              newGroups[groupId] = {
                groupName: groups[groupId].name,
                items: [klass]
              }
            }
          }
        })
      })
    })
  }

  return newGroups
}

export default defineStore('biocurations', {
  state: () => ({
    biocurations: []
  }),

  actions: {
    async load({ objectId, objectType }) {
      const { body: biocurationGroups } = await ControlledVocabularyTerm.where({
        type: [BIOCURATION_GROUP]
      })
      const { body: biocurations } = await BiocurationClassification.where({
        biocuration_classification_object_id: objectId,
        biocuration_classification_object_type: objectType
      })
      const groups = Object.assign(
        {},
        ...biocurationGroups.map((item) => ({
          [item.id]: {
            name: item.name,
            items: []
          }
        }))
      )

      this.biocurations = await makeGroup(groups, biocurations)
    }
  }
})
