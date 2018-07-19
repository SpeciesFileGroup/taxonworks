<template>
  <div>
    <div class="horizontal-left-content">
      <div>
        <catalog-number/>
      </div>
      <div>
        <bioclassification/>
      </div>
    </div>
    <buffered-component/>
    <depictions-component/>
  </div>
</template>

<script>

  import CatalogNumber from './catalogNumber.vue'
  import Bioclassification from './bioclassification.vue'
  import BufferedComponent from './bufferedData.vue'
  import DepictionsComponent from './depictions.vue'

  export default {
    components: {
      CatalogNumber,
      Bioclassification,
      BufferedComponent,
      DepictionsComponent
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