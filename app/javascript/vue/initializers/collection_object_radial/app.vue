<template>
  <collection-object-radial
    :id="id"
    type="graph"
    button-class="btn-co-radial"
    button-title="Collection object quick forms"
    :global-id="globalId"/>
</template>
<script>

  import CollectionObjectRadial from 'components/radials/object/radial.vue'

  export default {
    components: {
      CollectionObjectRadial
    },
    props: {
      id: {
        type: String,
        required: true
      },
      globalId: {
        type: String,
        required: true
      }
    }
  }
</script>