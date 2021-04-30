<template>
  <div>
    <button
      class="button normal-input button-default"
      @click="show = true">GEOLocate</button>
    <modal-component
      v-if="show"
      @close="show = false">
      <h3 slot="header">GEOLocate</h3>
      <div slot="body">
        <div class="field">
          <label>Coordinates:</label>
          <textarea
            class="full_width"
            rows="5"
            v-model="iframe_response">
          </textarea>
        </div>
      </div>
      <div slot="footer">
        <button
          type="button"
          class="normal-input button button-submit"
          :disabled="!validateFields"
          @click="createShape">
          Add
        </button>
      </div>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/modal'
import convertDMS from 'helpers/parseDMS.js'

export default {
  components: {
    ModalComponent
  },
  computed: {
    validateFields () {
      return this.iframe_response
    }
  },
  data () {
    return {
      show: false,
      iframe_response: undefined
    }
  },
  methods: {
    createShape () {
      this.$emit('create', this.iframe_response)
      this.iframe_response = undefined
      this.show = false
    }
  }
}
</script>

<style lang="scss" scoped>
  ::v-deep .modal-container {
    max-width: 500px;
  }
</style>