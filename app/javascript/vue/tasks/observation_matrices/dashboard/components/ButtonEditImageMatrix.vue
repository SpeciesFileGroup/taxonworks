<template>
  <button
    class="button normal-input button-default"
    @click="openImageMatrix"
    :disabled="!otuIds.length"
  >
    Edit image matrix
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
    openImageMatrix () {
      window.open(`${RouteNames.ImageMatrix}?otu_filter=${this.otuIds.join('|')}`, '_blank')
    }
  }
}
</script>
