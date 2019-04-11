<template>
  <div>
    <taxon-name-component/>
    <precision-component/>
    <updated-component/>
  </div>
</template>

<script>

import taxonNameComponent from './filters/name'
import PrecisionComponent from './filters/precision.vue'
import UpdatedComponent from './filters/updated'

export default {
  components: {
    taxonNameComponent,
    PrecisionComponent,
    UpdatedComponent
  },
  data() {
    return {

    }
  }
}
</script>

<style>

</style>
