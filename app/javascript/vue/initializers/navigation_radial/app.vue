<template>
  <radial-object :global-id="globalId" />
</template>
<script>
import radialObject from '@/components/radials/navigation/radial.vue'

export default {
  components: {
    radialObject
  },
  props: {
    globalId: {
      type: String,
      required: true
    }
  }
}
</script>
