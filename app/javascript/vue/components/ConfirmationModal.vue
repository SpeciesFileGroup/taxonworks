<template>
  <modal-component
    v-if="showModal"
    @close="_cancel"
  >
    <template #header>
      <h3>{{ title }}</h3>
    </template>
    <template #body>
      <div>
        <div v-html="message" />
        <div v-show="confirmationWord">
          <p>Type "{{ confirmationWord }}" to proceed.</p>
          <input
            type="text"
            class="full_width"
            ref="inputtext"
            v-model="inputValue"
            :placeholder="`Write ${confirmationWord} to continue`"
            @keydown.enter="isConfirmationWordTyped && _confirm()"
          >
        </div>
      </div>
    </template>
    <template #footer>
      <div class="horizontal-right-content">
        <button
          type="button"
          class="button normal-input"
          :disabled="!isConfirmationWordTyped"
          :class="[`button-${typeButton}`]"
          @click="_confirm"
        >
          {{ okButton }}
        </button>
        <button
          v-if="cancelButton"
          class="button normal-input button-default margin-small-left"
          @click="_cancel"
        >
          {{ cancelButton }}
        </button>
      </div>
    </template>
  </modal-component>
</template>

<script>
import ModalComponent from 'components/ui/Modal'

export default {
  name: 'ConfirmDialogue',

  components: { ModalComponent },

  data: () => ({
    title: undefined,
    message: undefined,
    okButton: undefined,
    cancelButton: undefined,
    typeButton: 'delete',
    showModal: false,
    resolvePromise: undefined,
    rejectPromise: undefined,
    confirmationWord: undefined,
    inputValue: undefined
  }),

  computed: {
    isConfirmationWordTyped () {
      return !this.confirmationWord || this.confirmationWord?.toLowerCase() === this.inputValue?.toLowerCase()
    }
  },

  methods: {
    show (opts = {}) {
      this.title = opts.title
      this.message = opts.message
      this.okButton = opts.okButton || 'Accept'
      this.typeButton = opts.typeButton || 'delete'
      this.cancelButton = opts.cancelButton
      this.confirmationWord = opts.confirmationWord
      this.showModal = true
      this.inputValue = undefined

      if (opts.confirmationWord) {
        this.$nextTick(() => {
          this.$refs.inputtext.focus()
        })
      }

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
