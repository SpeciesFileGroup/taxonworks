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
      <h3 slot="header">Create property</h3>
      <div slot="body">
        <div class="field">
          <label>Name</label>
          <br>
          <input
            class="full_width"
            v-model="controlVocabularyTerm.name"
            type="text">
        </div>
        <div class="field">
          <label>Definition</label>
          <br>
          <textarea
            class="full_width"
            v-model="controlVocabularyTerm.definition"
            rows="5">
          </textarea>
        </div>
        <div class="field">
          <label>URI</label>
          <br>
          <input
            class="full_width"
            v-model="controlVocabularyTerm.uri"
            type="text">
        </div>
        <div class="field">
          <label>CSS color</label>
          <br>
          <input
            v-model="controlVocabularyTerm.css_color"
            type="color">
        </div>
        <button
          class="button normal-input button-submit"
          @click="save">
          Save
        </button>
      </div>
    </modal-component>
  </div>
</template>

<script>

import { ControlledVocabularyTerm } from 'routes/endpoints'
import ModalComponent from 'components/modal'

export default {
  components: {
    ModalComponent
  },
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
      if (this.controlVocabularyTerm.id) {
        ControlledVocabularyTerm.update(this.controlVocabularyTerm.id, { controlled_vocabulary_term: this.controlVocabularyTerm }).then(response => {
          this.$emit('update', response.body)
          this.showModal = false
          this.controlVocabularyTerm = this.resetCVT()
        })
      } else {
        ControlledVocabularyTerm.create({ controlled_vocabulary_term: this.controlVocabularyTerm }).then(response => {
          this.$emit('create', response.body)
          this.showModal = false
          this.controlVocabularyTerm = this.resetCVT()
        })
      }
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

<style>

</style>