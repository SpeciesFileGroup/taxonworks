<template>
  <div>
    <button
      type="button"
      class="button normal-input button-default"
      @click="showModal = true">
      Accession metadata
    </button>
    <modal-component
      v-if="showModal"
      @close="showModal = false">
      <h3 slot="header">Accession metadata</h3>
      <div slot="body">
        <div class="field">
          <label>
            Accessioned at
          </label><br>
          <input
            type="date"
            class="full_width"
            v-model="collectionObject.accessioned_at">
        </div>
        <div class="field">
          <label>
            Deaccessioned at
          </label><br>
            <input
              type="date"
              class="full_width"
              v-model="collectionObject.deaccessioned_at">
        </div>
        <div class="field">
          <label>
            Deaccession reason
          </label><br>
          <input
            type="text"
            class="full_width"
            v-model="collectionObject.deaccession_reason">
        </div>
        <button
          type="button"
          @click="saveAccession"
          class="button normal-input button-submit">
          Save
        </button>
      </div>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/modal'
import { ActionNames } from '../../store/actions/actions'

export default {
  components: {
    ModalComponent
  },
  props: {
    collectionObject: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      showModal: false
    }
  },
  methods: {
    saveAccession() {
      this.$store.dispatch(ActionNames.SaveCollectionObject, this.collectionObject).then(() => {
        TW.workbench.alert.create('Collection object was successfully saved.', 'notice')
      })
    }
  }
}
</script>

<style scoped>
  /deep/ .modal-container {
    width: 300px !important
  }
</style>