<template>
  <div class="horizontal-left-content">
    <div>
      <catalog-number/>
      <div>
        <div>
          <label>Buffered determination</label>
          <br>
          <textarea rows="5"/>
        </div>
        <div>
          <label>Buffered collecting event</label>
          <br>
          <textarea rows="5"/>
        </div>
        <div>
          <label>Buffered other labels</label>
          <br>
          <textarea rows="5"/>
        </div>
      </div>
    </div>
    <div>
      <bioclassification/>
    </div>
  </div>
</template>

<script>

  import CatalogNumber from './catalogNumber.vue'
  import Bioclassification from './bioclassification.vue'

  export default {
    components: {
      CatalogNumber,
      Bioclassification
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