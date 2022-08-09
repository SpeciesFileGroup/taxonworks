<template>
  <button
    class="button normal-input button-default"
    :disabled="!otuIds.length"
    @click="openImageMatrix">
    View image matrix
  </button>
</template>

<script>

import { RouteNames } from 'routes/routes'

export default {
  props: {
    otuIds: {
      type: Array,
      default: () => []
    }
  },

  methods: {
    openImageMatrix () {
      window.open(`${RouteNames.ImageMatrix}?otu_filter=${this.otuIds.join('|')}&view=true`, '_blank')
    }
  }
}
</script>
