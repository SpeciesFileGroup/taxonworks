<template>
  <radial-annotator
    :id="id"
    type="graph"
    buttonClass="btn-hexagon-w button-default"
    :show-count="showCount"
    :global-id="globalId"/>
</template>
<script>

  import RadialAnnotator from 'components/annotator/annotator.vue'

  export default {
    components: {
      RadialAnnotator
    },
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
      }
    }
  }
</script>