<template>
  <button
    v-if="showButton"
    type="button"
    :disabled="isProcessing || isProcessingImport"
    class="button normal-input button-submit"
    @click="importRow">
    {{ enableStatus[row.status] }}
  </button>
</template>

<script>

import { ActionNames } from '../store/actions/actions'
import { GetterNames } from '../store/getters/getters'

export default {
  props: {
    row: {
      type: Object,
      required: true
    }
  },
  computed: {
    showButton () {
      return Object.keys(this.enableStatus).includes(this.row.status)
    },

    isProcessingImport () {
      return this.$store.getters[GetterNames.GetSettings].isProcessing
    }
  },
  data () {
    return {
      enableStatus: {
        Ready: 'Import',
        Errored: 'Retry'
      },
      isProcessing: false
    }
  },
  methods: {
    async importRow () {
      this.isProcessing = true
      await this.$store.dispatch(ActionNames.ImportRow, this.row.id)
      this.isProcessing = false
    }
  }
}
</script>

<style>

</style>