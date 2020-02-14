<template>
  <collection-object-radial
    :id="id"
    type="graph"
    button-class="btn-co-radial"
    :global-id="globalId"/>
</template>
<script>

  import CollectionObjectRadial from 'components/otu/otu_radial/radial.vue'

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