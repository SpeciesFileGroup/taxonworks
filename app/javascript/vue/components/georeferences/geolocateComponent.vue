<template>
  <div>
    <button
      class="button normal-input button-default"
      @click="show = true">GEOLocate</button>
    <modal-component
      v-if="show"
      @close="show = false">
      <template #header>
        <h3>GEOLocate</h3>
      </template>
      <template #body>
        <div class="field">
          <label>Coordinates:</label>
          <textarea
            class="full_width"
            rows="5"
            v-model="iframe_response"/>
        </div>
      </template>
      <template #footer>
        <button
          type="button"
          class="normal-input button button-submit"
          :disabled="!validateFields"
          @click="createShape">
          Add
        </button>
      </template>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/ui/Modal'

export default {
  components: { ModalComponent },

  emits: ['create'],

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
  :deep(.modal-container) {
    max-width: 500px;
  }
</style>
