<template>
  <div>
    <h3>Taxon Names</h3>
  </div>
</template>
<script>
  export default {
    props: {
      value: {

      },
      source_id: {
        type: Integer,
        default: 0
      },
    },
    data() {
      return {
        taxon_names_list: []
      }
    }
  }
</script>