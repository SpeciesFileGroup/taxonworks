<template>
  <div>
    <button
      class="button normal-input button-submit"
      type="button"
      @click="showModal = true">
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
        <button
          class="button normal-input button-submit"
          @click="create">
          Create
        </button>
      </div>
    </modal-component>
  </div>
</template>

<script>

import { CreateProperty } from '../../request/resource'
import ModalComponent from 'components/modal'

export default {
  components: {
    ModalComponent
  },
  data () {
    return {
      controlVocabularyTerm: {
        type: 'BiologicalProperty',
        name: undefined,
        definition: undefined
      },
      showModal: false
    }
  },
  methods: {
    create() {
      CreateProperty(this.controlVocabularyTerm).then(response => {
        this.$emit('create', response.body)
        this.showModal = false
      })
    }
  }
}
</script>

<style>

</style>