<template>
  <div :id="id">
    <radial-annotator :globalId="globalId"></radial-annotator>
  </div>
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