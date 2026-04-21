import { reactive, computed } from 'vue'
import { ControlledVocabularyTerm, Tag } from '@/routes/endpoints'
import { CONTROLLED_VOCABULARY_TERM } from '@/constants/index.js'

const state = reactive({
  biocurationGroups: [],
  biocurationClasses: [],
  biocurationTags: [],
  isLoading: false
})

export default () => {
  const actions = {
    requestBiocurationGroups: async () => {
      return ControlledVocabularyTerm.where({
        type: ['BiocurationGroup']
      }).then(({ body }) => {
        state.biocurationGroups = body
        actions.requestBiocurationTags()
      })
    },

    requestBiocurationClasses: async () => {
      return ControlledVocabularyTerm.where({
        type: ['BiocurationClass']
      }).then(({ body }) => {
        state.biocurationClasses = body
      })
    },

    createBiocurationClass: (controlled_vocabulary_term) => {
      ControlledVocabularyTerm.create({ controlled_vocabulary_term }).then(
        ({ body }) => {
          state.biocurationClasses.push(body)
          TW.workbench.alert.create(
            'Biocuration class item was successfully created.',
            'notice'
          )
        }
      )
    },

    createBiocurationGroup: (controlled_vocabulary_term) => {
      ControlledVocabularyTerm.create({ controlled_vocabulary_term }).then(
        ({ body }) => {
          state.biocurationGroups.push(body)
          TW.workbench.alert.create(
            'Biocuration group item was successfully created.',
            'notice'
          )
        }
      )
    },

    requestBiocurationTags: () => {
      const groupIds = state.biocurationGroups.map((g) => g.id)

      if (!groupIds.length) return

      Tag.where({
        keyword_id: groupIds,
        tag_object_type: CONTROLLED_VOCABULARY_TERM
      }).then(({ body }) => {
        state.biocurationTags = body
      })
    },

    destroyBiocurationGroup: (id) => {
      const index = state.biocurationGroups.findIndex((item) => item.id === id)

      ControlledVocabularyTerm.destroy(id).then((_) => {
        state.biocurationGroups.splice(index, 1)
        state.biocurationTags = state.biocurationTags.filter(
          (tag) => tag.keyword_id !== id
        )
        TW.workbench.alert.create(
          'Biocuration group item was successfully destroyed.',
          'notice'
        )
      })
    },

    addBiocurationTag: (groupId, classId) => {
      const tag = {
        tag_object_id: classId,
        tag_object_type: CONTROLLED_VOCABULARY_TERM,
        keyword_id: groupId
      }

      Tag.create({ tag }).then(({ body }) => {
        state.biocurationTags.push(body)
        TW.workbench.alert.create(
          'Biocuration class item was successfully added.',
          'notice'
        )
      })
    },

    removeBiocurationTag: (groupId, classId) => {
      const tag = state.biocurationTags.find(
        (item) => item.keyword_id === groupId && item.tag_object_id === classId
      )

      Tag.destroy(tag.id).then((_) => {
        const index = state.biocurationTags.findIndex(
          (item) => item.id === tag.id
        )
        state.biocurationTags.splice(index, 1)
        TW.workbench.alert.create(
          'Biocuration class item was successfully removed.',
          'notice'
        )
      })
    }
  }

  const getters = {
    getBiocurationGroups: () => state.biocurationGroups,
    getBiocurationClasses: () => state.biocurationClasses,

    getBiocurationTagsByGroupId: (groupId) =>
      state.biocurationTags.filter((tag) => tag.keyword_id === groupId),

    getUngroupedBiocurationClasses: () => {
      const groupedClassIds = new Set(
        state.biocurationTags.map((tag) => tag.tag_object_id)
      )

      return state.biocurationClasses.filter(
        (bc) => !groupedClassIds.has(bc.id)
      )
    }
  }

  return {
    state,
    actions,
    getters
  }
}
