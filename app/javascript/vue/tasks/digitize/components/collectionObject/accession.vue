<template>
  <div>
    <button
      type="button"
      class="button normal-input button-default"
      @click="setModalState(true)">
      Accession metadata
    </button>
    <modal-component
      v-if="showModal"
      @close="setModalState(false)">
      <h3 slot="header">Accession metadata</h3>
      <div slot="body">
        <div class="field">
          <label>
            Accessioned at
          </label><br>
          <input
            type="date"
            class="full_width"
            @change="unsaved = true"
            v-model="collectionObject.accessioned_at">
        </div>
        <div class="field">
          <label>
            Deaccessioned at
          </label><br>
          <input
            type="date"
            class="full_width"
            @change="unsaved = true"
            v-model="collectionObject.deaccessioned_at">
        </div>
        <div class="field">
          <label>
            Deaccession reason
          </label><br>
          <input
            type="text"
            class="full_width"
            @change="unsaved = true"
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

import ModalComponent from 'components/ui/Modal'
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
      showModal: false,
      unsaved: false
    }
  },

  methods: {
    saveAccession () {
      this.$store.dispatch(ActionNames.SaveCollectionObject, this.collectionObject).then(() => {
        TW.workbench.alert.create('Collection object was successfully saved.', 'notice')
        this.unsaved = false
      })
    },
    checkUnsaved () {
      if (this.unsaved && window.confirm('You have unsaved changes. Do you want to save it?')) {
        this.saveAccession()
      }
    },
    setModalState (value) {
      this.checkUnsaved()
      this.showModal = value
    }
  }
}
</script>

<style scoped>
  ::v-deep .modal-container {
    width: 300px !important
  }
</style>