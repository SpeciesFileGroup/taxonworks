<template>
  <otu-radial
    :id="id"
    type="graph"
    button-title="OTU quick forms"
    button-class="btn-hexagon-w button-default"
    :show-count="showCount"
    :global-id="globalId"/>
</template>
<script>

import OtuRadial from 'components/radials/object/radial.vue'

export default {
  components: { OtuRadial },

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
