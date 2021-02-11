<template>
  <modal-component v-if="showModal">
    <h3 slot="header">
      {{ title }}
    </h3>
    <div slot="body">
      <div v-html="message"/>
    </div>
    <div
      slot="footer"
      class="horizontal-right-content">
      <button
        type="button"
        class="button normal-input"
        :class="[`button-${typeButton}`]"
        @click="_confirm"
      >
        {{ okButton }}
      </button>
      <button
        class="button normal-input button-default margin-small-left"
        @click="_cancel">
        {{ cancelButton }}
      </button>
    </div>
  </modal-component>
</template>

<script>
import ModalComponent from 'components/modal.vue'

export default {
  name: 'ConfirmDialogue',
  components: { ModalComponent },
  data: () => ({
    title: undefined,
    message: undefined,
    okButton: undefined,
    cancelButton: 'Cancel',
    typeButton: 'delete',
    showModal: false,
    resolvePromise: undefined,
    rejectPromise: undefined
  }),

  methods: {
    show (opts = {}) {
      this.title = opts.title
      this.message = opts.message
      this.okButton = opts.okButton || 'Accept'
      this.typeButton = opts.typeButton || 'delete'
      if (opts.cancelButton) {
        this.cancelButton = opts.cancelButton
      }

      this.showModal = true
      return new Promise((resolve, reject) => {
        this.resolvePromise = resolve
        this.rejectPromise = reject
      })
    },

    _confirm () {
      this.showModal = false
      this.resolvePromise(true)
    },

    _cancel () {
      this.showModal = false
      this.resolvePromise(false)
    }
  }
}
</script>
