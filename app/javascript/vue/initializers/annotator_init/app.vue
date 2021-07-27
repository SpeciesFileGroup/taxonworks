<template>
  <radial-annotator
    :id="id"
    :show-count="showCount"
    :global-id="globalId"
    :pulse="pulse"/>
</template>
<script>

import radialAnnotator from 'components/radials/annotator/annotator.vue'

export default {
  components: { radialAnnotator },

  props: {
    id: {
      type: String,
      required: true
    },

    globalId: {
      type: String,
      required: true
    },

    showCount: {
      type: Boolean,
      default: false
    },

    pulse: {
      type: Boolean,
      default: false
    }
  }
}
</script>
