<template>
  <td>
    <button
      v-if="!alreadyImported"
      type="button"
      :disabled="isProcessing"
      class="button normal-input button-submit"
      @click="importRow">
      {{ isProcessing ? 'Importing' : 'Import' }}
    </button>
  </td>
</template>

<script>

import { ActionNames } from '../store/actions/actions'

export default {
  props: {
    row: {
      type: Object,
      required: true
    }
  },
  computed: {
    alreadyImported () {
      return this.row.status === 'Imported'
    }
  },
  data () {
    return {
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