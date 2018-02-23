<template>
  <otu-radial
    :id="id"
    :taxon-name="taxonName"
    :taxon-id="taxonId"/>
</template>
<script>

  import OtuRadial from '../components/otu/otu.vue'

  export default {
    components: {
      OtuRadial
    },
    props: {
      id: {
        type: String,
        required: true
      },
      taxonId: {
        type: String,
        required: true
      },
      taxonName: {
        type: String,
        required: true
      }
    }
  }
</script>