<template>
  <otu-radial
    :id="id"
    type="graph"
    buttonClass="btn-hexagon-w button-default"
    :show-count="showCount"
    :global-id="globalId"/>
</template>
<script>

  import OtuRadial from 'components/otu/otu_radial/radial.vue'

  export default {
    components: {
      OtuRadial
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