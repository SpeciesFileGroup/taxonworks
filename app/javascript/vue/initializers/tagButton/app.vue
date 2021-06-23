<template>
  <default-tag
    :count="count"
    show-count
    :global-id="globalId"/>
</template>
<script>

import DefaultTag from 'components/defaultTag.vue'

export default {
  components: { DefaultTag },

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
