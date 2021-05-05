<template>
  <button
    type="button"
    class="button button-default normal-input"
    :disabled="!otuIds.length"
    @click="openImageMatrix">
    Image matrix
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
      window.open(`${RouteNames.ImageMatrix}?otu_filter=${this.otuIds.join('|')}`, '_self')
    }
  }
}
</script>
