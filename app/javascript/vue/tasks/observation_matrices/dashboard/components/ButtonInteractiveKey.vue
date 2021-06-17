<template>
  <button
    type="button"
    class="button normal-input button-default"
    :disabled="!otuIds.length"
    @click="openInteractiveKeys()">
    Open in interactive keys
  </button>
</template>

<script>

import { RouteNames } from 'routes/routes'

export default {
  props: {
    otuIds: {
      type: Array,
      required: true
    }
  },

  methods: {
    openInteractiveKeys () {
      window.open(`${RouteNames.InteractiveKeys}?otu_filter=${this.otuIds.join('|')}`, '_blank')
    }
  }
}
</script>
