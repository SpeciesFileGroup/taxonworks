<template>
  <default-confidence :global-id="globalId"/>
</template>
<script>

  import DefaultConfidence from 'components/defaultConfidence.vue'

  export default {
    components: {
      DefaultConfidence
    },
    props: {
      globalId: {
        type: String,
        required: true
      }
    }
  }
</script>