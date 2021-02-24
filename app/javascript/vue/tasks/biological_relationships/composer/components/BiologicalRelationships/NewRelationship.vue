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
        <div class="field label-above">
          <label>Inverted name</label>
          <input
            v-model="biologicalRelationship.inverted_name"
            class="full_width"
            type="text">
        </div>
        <ul class="no_bullets">
          <li>
            <label>
              <input
                v-model="biologicalRelationship.is_transitive"
                type="checkbox">
              Is transitive
            </label>
          </li>
          <li>
            <label>
              <input
                v-model="biologicalRelationship.is_reflexive"
                type="checkbox">
              Is reflexive
            </label>
          </li>
        </ul>
        <button
          class="button normal-input button-submit margin-medium-top"
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
      biologicalRelationship: this.newBiologicalRelationship(),
      showModal: false
    }
  },
  methods: {
    create () {
      CreateBiologicalRelationship(this.biologicalRelationship).then(response => {
        this.$emit('create', response.body)
        this.showModal = false
      })
    },
    newBiologicalRelationship () {
      return {
        name: undefined,
        inverted_name: undefined,
        is_transitive: undefined,
        is_reflexive: undefined
      }
    },
    openModal () {
      this.biologicalRelationship = this.newBiologicalRelationship()
      this.showModal = true
    }
  }
}
</script>

<style>

</style>