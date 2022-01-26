import { reactive, computed } from 'vue'
import { ControlledVocabularyTerm } from 'routes/endpoints'

const state = reactive({
  biocurationGroups: [],
  biocurationClasses: []
})

export default () => {
  const actions = {
    requestBiocurationGroups: () => {
      ControlledVocabularyTerm.where({ type: ['BiocurationGroup'] }).then(({ body }) => {
        state.biocurationGroups = body
      })
    },

    requestBiocurationClasses: () => {
      ControlledVocabularyTerm.where({ type: ['BiocurationClass'] }).then(({ body }) => {
        state.biocurationClasses = body
      })
    },

    createBiocurationClass: (controlled_vocabulary_term) => {
      ControlledVocabularyTerm.create({ controlled_vocabulary_term }).then(({ body }) => {
        state.biocurationClasses.push(body)
        TW.workbench.alert.create('Biocuration group item was successfully created.', 'notice')
      })
    },

    createBiocurationGroup: (controlled_vocabulary_term) => {
      ControlledVocabularyTerm.create({ controlled_vocabulary_term }).then(({ body }) => {
        state.biocurationGroups.push(body)
        TW.workbench.alert.create('Biocuration group item was successfully created.', 'notice')
      })
    },

    destroyBiocurationGroup: (id) => {
      const index = state.biocurationGroups.findIndex(item => item.id === id)

      ControlledVocabularyTerm.destroy(id).then(_ => {
        state.biocurationGroups.splice(index, 1)
        TW.workbench.alert.create('Biocuration group item was successfully destroyed.', 'notice')
      })
    }
  }

  const getters = {
    getBiocurationGroups: () => state.biocurationGroups,
    getBiocurationClasses: () => state.biocurationClasses
  }

  return {
    state,
    actions,
    getters
  }
}
