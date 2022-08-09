<template>
  <button
    type="button"
    class="button normal-input button-submit button-size margin-small-left"
    :disabled="!source.id"
    v-hotkey="shortcuts"
    @click="showModal = true"
  >
    Clone
  </button>
  <modal-component
    v-show="showModal"
    @close="showModal = false"
  >
    <template #header>
      <h3>Clone source</h3>
    </template>
    <template #body>
      <p>
        This will clone the current source.
      </p>
      <p>Are you sure you want to proceed? Type "{{ checkWord }}" to proceed.</p>
      <input
        type="text"
        class="full_width"
        v-model="inputValue"
        @keypress.enter.prevent="cloneSource()"
        ref="inputtext"
        :placeholder="`Write ${checkWord} to continue`"
      >
    </template>
    <template #footer>
      <button
        type="button"
        class="button normal-input button-submit button-size"
        :disabled="!isWordTyped"
        @click="cloneSource()"
      >
        Clone
      </button>
    </template>
  </modal-component>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { ActionNames } from '../store/actions/actions'
import ModalComponent from 'components/ui/Modal.vue'
import platformKey from 'helpers/getPlatformKey'

export default {
  components: {
    ModalComponent
  },

  computed: {
    source () {
      return this.$store.getters[GetterNames.GetSource]
    },

    isWordTyped () {
      return this.inputValue.toUpperCase() === this.checkWord
    },

    shortcuts () {
      const keys = {}

      keys[`${platformKey()}+c`] = this.openModal

      return keys
    }
  },

  data () {
    return {
      showModal: false,
      inputValue: '',
      checkWord: 'CLONE'
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
    openModal () {
      this.showModal = true
    },

    cloneSource () {
      if (!this.isWordTyped) return
      this.$store.dispatch(ActionNames.CloneSource)
      this.showModal = false
    }
  }
}
</script>

<style scoped>
  .button-size {
    width: 100px;
  }
</style>
