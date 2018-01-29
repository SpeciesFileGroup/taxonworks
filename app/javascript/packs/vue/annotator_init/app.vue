<template>
  <radial-annotator :id="id" :global-id="globalId"/>
</template>
<script>

import radialAnnotator from '../components/annotator/annotator.vue'

export default {
  components: {
    radialAnnotator
  },
  props: {
    id: String,
    globalId: String
  }
}
</script>
