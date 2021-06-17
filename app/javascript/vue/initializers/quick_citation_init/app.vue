<template>
  <quick-citation
    :id="id"
    :class="klass"
    :global-id="globalId"
    :source-id="sourceId"/>
</template>
<script>

import QuickCitation from 'components/citations/quick.vue'

export default {
  components: { QuickCitation },

  props: {
    id: {
      type: String,
      required: true
    },

    globalId: {
      type: String,
      required: true
    },

    sourceId: {
      type: [String, Number],
      required: true
    },

    klass: {
      type: String,
      default: undefined
    }
  }
}
</script>
