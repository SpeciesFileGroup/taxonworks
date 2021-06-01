<template>
  <div>
    <button
      type="button"
      class="button normal-input button-submit button-size"
      :disabled="!source.id"
      v-shortkey="[getOSKey, 'c']"
      @shortkey="showModal = true"
      @click="showModal = true">
      Clone
    </button>
    <modal-component
      v-show="showModal"
      @close="showModal = false">
      <h3 slot="header">Clone source</h3>
      <div slot="body">
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
          :placeholder="`Write ${checkWord} to continue`">
      </div>
      <div slot="footer">
        <button
          type="button"
          class="button normal-input button-submit button-size"
          :disabled="!isWordTyped"
          @click="cloneSource()">
          Clone
        </button>
      </div>
    </modal-component>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { ActionNames } from '../store/actions/actions'
import ModalComponent from 'components/ui/Modal.vue'

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
    getOSKey () {
      return (navigator.platform.indexOf('Mac') > -1 ? 'ctrl' : 'alt')
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
