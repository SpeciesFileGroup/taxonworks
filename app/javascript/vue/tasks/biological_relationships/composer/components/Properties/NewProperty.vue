<template>
  <div>
    <button
      class="button normal-input button-submit"
      type="button"
      @click="openModal">
      New
    </button>
    <modal-component
      v-if="showModal"
      @close="showModal = false">
      <template #header>
        <h3>Create property</h3>
      </template>
      <template #body>
        <div class="field label-above">
          <label>Name</label>
          <input
            class="full_width"
            v-model="controlVocabularyTerm.name"
            type="text">
        </div>
        <div class="field label-above">
          <label>Definition</label>
          <textarea
            class="full_width"
            v-model="controlVocabularyTerm.definition"
            rows="5"/>
        </div>
        <div class="field label-above">
          <label>URI</label>
          <input
            class="full_width"
            v-model="controlVocabularyTerm.uri"
            type="text">
        </div>
        <div class="field label-above">
          <label>Label color</label>
          <input
            v-model="controlVocabularyTerm.css_color"
            type="color">
        </div>
        <button
          class="button normal-input button-submit"
          @click="save">
          Save
        </button>
      </template>
    </modal-component>
  </div>
</template>

<script>

import { ControlledVocabularyTerm } from 'routes/endpoints'
import ModalComponent from 'components/ui/Modal'

export default {
  components: {
    ModalComponent
  },

  emits: [
    'update:modelValue',
    'save'
  ],

  data () {
    return {
      controlVocabularyTerm: this.resetCVT(),
      showModal: false
    }
  },

  methods: {
    openModal () {
      this.showModal = true
      this.controlVocabularyTerm = this.resetCVT()
    },

    save () {
      const saveRecord = this.controlVocabularyTerm.id
        ? ControlledVocabularyTerm.update(this.controlVocabularyTerm.id, { controlled_vocabulary_term: this.controlVocabularyTerm })
        : ControlledVocabularyTerm.create({ controlled_vocabulary_term: this.controlVocabularyTerm })

      saveRecord.then(response => {
        this.$emit('save', response.body)
        this.showModal = false
        this.controlVocabularyTerm = this.resetCVT()
      })
    },

    resetCVT () {
      return {
        id: undefined,
        type: 'BiologicalProperty',
        name: undefined,
        definition: undefined,
        uri: undefined,
        css_color: undefined
      }
    },

    setProperty (property) {
      this.controlVocabularyTerm = property
      this.showModal = true
    }
  }
}
</script>
