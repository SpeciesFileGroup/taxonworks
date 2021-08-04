<template>
  <default-confidence
    :count="count"
    :global-id="globalId"/>
</template>
<script>

import DefaultConfidence from 'components/defaultConfidence.vue'

export default {
  components: { DefaultConfidence },

  props: {
    globalId: {
      type: String,
      required: true
    },

    count: {
      type: [String, Number],
      default: undefined
    }
  }
}
</script>
