<template>
  <div>
    <button
      type="button"
      class="button normal-input button-submit"
      :disabled="disabled"
      @click="setModalView(true)">
      Merge people
    </button>
    <modal-component
      v-show="showModal"
      @close="setModalView(false)">
      <h3 slot="header">Merge people</h3>
      <div slot="body">
        <p>
          This will merge all selected match people to selected person.
          Are you sure you want to proceed? Type "{{ checkWord }}" to proceed.
        </p>
        <input
          type="text"
          class="full_width"
          v-model="inputValue"
          @keypress.enter.prevent="emitMerge()"
          ref="inputtext"
          :placeholder="`Write ${checkWord} to continue`">
      </div>
      <div slot="footer">
        <button
          type="button"
          class="button normal-input button-submit"
          :disabled="checkInput"
          @click="emitMerge()">
          Merge
        </button>
      </div>
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
      showModal: false,
      inputValue: '',
      checkWord: 'MERGE'
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
  methods: {
    setModalView (value) {
      this.showModal = value
    },
    emitMerge () {
      this.$emit('onAccept', true)
    }
  }
}
</script>
