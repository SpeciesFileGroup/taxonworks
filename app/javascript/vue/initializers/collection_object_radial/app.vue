<template>
  <collection-object-radial
    :id="id"
    type="graph"
    buttonClass="btn-hexagon-w button-default"
    :global-id="globalId"/>
</template>
<script>

  import CollectionObjectRadial from 'components/collectionObjects/radial/radial.vue'

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