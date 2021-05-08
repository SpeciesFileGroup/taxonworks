<template>
  <a
    :class="{ disabled: !this.otuIds.length }"
    :disabled="!otuIds.length"
    :href="openImageMatrix">
    Image matrix
  </a>
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

  computed: {
    openImageMatrix () {
      return this.otuIds.length ? `${RouteNames.ImageMatrix}?otu_filter=${this.otuIds.join('|')}` : false
    }
  }
}
</script>
