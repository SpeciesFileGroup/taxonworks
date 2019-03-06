<template>
  <radial-object
    :global-id="globalId"/>
</template>
<script>

  import radialObject from 'components/radial_object/radialObject.vue'

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
