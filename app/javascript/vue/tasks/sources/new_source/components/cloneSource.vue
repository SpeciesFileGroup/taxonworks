<template>
  <button
    type="button"
    class="button normal-input button-submit button-size"
    :disabled="!source.id"
    v-hotkey="shortcuts"
    @click="cloneSource"
  >
    Clone
  </button>
  <ConfirmationModal ref="confirmationModal" />
</template>

<script>
import { GetterNames } from '../store/getters/getters'
import { ActionNames } from '../store/actions/actions'
import platformKey from '@/helpers/getPlatformKey'
import ConfirmationModal from '@/components/ConfirmationModal.vue'

export default {
  components: {
    ConfirmationModal
  },

  computed: {
    source() {
      return this.$store.getters[GetterNames.GetSource]
    },

    shortcuts() {
      const keys = {}

      keys[`${platformKey()}+c`] = this.cloneSource

      return keys
    }
  },

  methods: {
    async cloneSource() {
      const ok = await this.$refs.confirmationModal.show({
        title: 'Clone source',
        message:
          'This will clone the current source. Are you sure you want to proceed?',
        confirmationWord: 'CLONE',
        okButton: 'Clone',
        cancelButton: 'Cancel',
        typeButton: 'submit'
      })

      if (ok) {
        this.$store.dispatch(ActionNames.CloneSource)
      }
    }
  }
}
</script>

<style scoped>
.button-size {
  width: 100px;
}
</style>
