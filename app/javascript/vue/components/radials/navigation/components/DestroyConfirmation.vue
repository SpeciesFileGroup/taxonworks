<template>
  <modal-component
    @close="closeModal"
    :containerStyle="{ 'min-width': '300px', 'max-width': '400px' }">
    <template #header>
      <h3>Destroy record</h3>
    </template>
    <template #body>
      <p>This will destroy the record. Are you sure you want to proceed? Type "{{ checkWord }}" to proceed.</p>
      <input
        type="text"
        class="full_width"
        v-model="inputValue"
        @keypress.enter.prevent="emitConfirm()"
        ref="inputtext"
        :placeholder="`Write ${checkWord} to continue`">
    </template>
    <template #footer>
      <button
        type="button"
        class="button normal-input button-delete"
        :disabled="checkInput"
        @click="emitConfirm()">
        Destroy
      </button>
    </template>
  </modal-component>
</template>

<script>

import ModalComponent from 'components/ui/Modal.vue'

export default {
  components: { ModalComponent },

  props: {
    disabled: {
      type: Boolean,
      default: false
    }
  },

  emits: [
    'confirm',
    'close'
  ],

  computed: {
    checkInput () {
      return this.inputValue.toUpperCase() !== this.checkWord
    }
  },

  data () {
    return {
      inputValue: '',
      checkWord: 'DELETE',
      showModal: false
    }
  },

  mounted () {
    this.$refs.inputtext.focus()
  },

  methods: {
    emitConfirm () {
      this.$emit('confirm', true)
      this.closeModal()
    },

    closeModal () {
      this.$emit('close')
    }
  }
}
</script>
