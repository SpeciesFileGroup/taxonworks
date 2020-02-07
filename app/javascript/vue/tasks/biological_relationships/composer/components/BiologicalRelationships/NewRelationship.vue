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
      <h3 slot="header">Create biological relationship</h3>
      <div slot="body">
        <div class="field">
          <label>Name</label>
          <br>
          <input
            v-model="biologicalRelationship.name"
            class="full_width"
            type="text">
        </div>
        <div class="field">
          <label>Inverted name</label>
          <br>
          <input
            v-model="biologicalRelationship.inverted_name"
            class="full_width"
            type="text">
        </div>
        <div class="field">
          <input
            v-model="biologicalRelationship.is_transitive"
            type="checkbox">
          <label>Is transitive</label>
        </div>
        <div class="field">
          <input
            v-model="biologicalRelationship.is_reflexive"
            type="checkbox">
          <label>Is reflexive</label>
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

import ModalComponent from 'components/modal'
import { CreateBiologicalRelationship } from '../../request/resource'

export default {
  components: {
    ModalComponent
  },
  data () {
    return {
      biologicalRelationship: {
        name: undefined, 
        inverted_name: undefined, 
        is_transitive: undefined, 
        is_reflexive: undefined
      },
      showModal: false
    }
  },
  methods: {
    create() {
      CreateBiologicalRelationship(this.biologicalRelationship).then(response => {
        this.$emit('create', response.body)
        this.showModal = false
      })
    }
  }
}
</script>

<style>

</style>