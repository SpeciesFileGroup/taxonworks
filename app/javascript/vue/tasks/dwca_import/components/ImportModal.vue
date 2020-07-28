<template>
  <div>
    <button
      @click="$emit('import')"
      :disabled="disabled"
      class="button normal-input button-submit">
      Import
    </button>
    <modal-component
      :container-style="{
        width: '700px'
      }">
      <h3>Import dataset</h3>
      <div slot="body">
        <div>
          <transition name="bounce">
            <div
              v-if="isProcessing"
              class="show-import-process panel">
              <spinner-component
                legend="Importing rows... please wait."
              />
            </div>
          </transition>
        </div>
        <button
          type="button"
          class="button normal-input button-default margin-medium-top"
          @click="processImport">
          Cancel
        </button>
      </div>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/modal'

export default {
  components: {
    ModalComponent
  },
  data () {
    return {
      isProcessing: false
    }
  },
  methods: {
    processImport () {
      this.isProcessing = true
      ImportRows(this.importId).then(response => {
        if (response.body.results.length) {
          response.body.results.forEach(row => {
            this.updateRow(row)
          })
          //this.processImport()
        } else {
          this.isProcessing = false
        }
      }, () => {
        this.isProcessing = false
      })
    },
  }
}
</script>
