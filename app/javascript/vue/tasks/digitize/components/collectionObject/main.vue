<template>
  <div class="horizontal-left-content">
    <div>
      <catalog-number/>
      <buffered-component/>
    </div>
    <div>
      <bioclassification/>
    </div>
  </div>
</template>

<script>

  import CatalogNumber from './catalogNumber.vue'
  import Bioclassification from './bioclassification.vue'
  import BufferedComponent from './bufferedData.vue'

  export default {
    components: {
      CatalogNumber,
      Bioclassification,
      BufferedComponent
    },
    computed: {
    },
    data() {
      return {
        types: [],
        labelRepository: undefined,
        labelEvent: undefined
      }
    }
  }
</script>