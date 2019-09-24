<template>
  <otu-button
    :id="id"
    :taxon-name="taxonName"
    :redirect="redirect"
    :taxon-id="taxonId"/>
</template>
<script>

  import OtuButton from 'components/otu/otu.vue'

  export default {
    components: {
      OtuButton
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
      },
      redirect: {
        type: Boolean,
        required: true
      }
    }
  }
</script>