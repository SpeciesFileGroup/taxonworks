<template>
  <div>
    <modal-component
      v-if="openModal"
      @close="openModal = false">
      <template #header>
        <h3>Destroy all observations</h3>
      </template>
      <template #body>
        <div>
          <p>
            This will destroy all observations in this row. Are you sure you want to proceed? Type "DELETE" to proceed.
          </p>
          <input
            type="text"
            class="full_width"
            v-model="value"
            placeholder="Write DELETE to continue">
        </div>
      </template>
      <template #footer>
        <button 
          type="button"
          class="button normal-input button-delete"
          :disabled="checkInput"
          @click="sendEvent()">
          Delete all
        </button>
      </template>
    </modal-component>
    <button
      type="button"
      class="button normal-input button-delete"
      @click="openModal = true">
      Destroy all observations in row
    </button>
  </div>
</template>

<script>

import ModalComponent from 'components/ui/Modal'

export default {
  components: {
    ModalComponent
  },
  computed: {
    checkInput() {
      return this.value.toUpperCase() != 'DELETE'
    }
  },
  data() {
    return {
      openModal: false,
      value: ''
    }
  },
  methods: {
    sendEvent() {
      this.$emit('onConfirm', true)
      this.openModal = false
    }
  }
}
</script>
