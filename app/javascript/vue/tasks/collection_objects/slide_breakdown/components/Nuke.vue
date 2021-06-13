<template>
  <div>
    <button
      type="button"
      :disabled="disabled"
      class="button normal-input button-delete "
      @click="showModal = true">Nuke
    </button>
    <modal-component
      v-show="showModal"
      @close="showModal = false">
      <template #header>
        <h3>Destroy collection objects</h3>
      </template>
      <template #body>
        <p>This will ALSO DESTROY specimens that matched assigned identifiers, not just those created de-novo in this tool. Are you sure you want to proceed? Type "{{ checkWord }}" to proceed.</p>
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
          NUKE
        </button>
      </template>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/ui/Modal.vue'

export default {
  components: {
    ModalComponent
  },
  props: {
    disabled: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    checkInput () {
      return this.inputValue.toUpperCase() !== this.checkWord
    }
  },
  data () {
    return {
      inputValue: '',
      checkWord: 'NUKE',
      showModal: false
    }
  },
  watch: {
    showModal: {
      handler (newVal) {
        if (newVal) {
          this.$nextTick(() => {
            this.$refs.inputtext.focus()
          })
        }
      }
    }
  },

  mounted() {
    this.$refs.inputtext.focus()
  },

  methods: {
    emitConfirm () {
      this.$emit('confirm', true)
      this.showModal = false
    }
  }
}
</script>
