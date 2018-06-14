<template>
  <div>
    <catalog-number/>
    <div>
      <div>
        <label>Buffered determination</label>
        <textarea rows="5"/>
      </div>
      <div>
        <label>Buffered collecting event</label>
        <textarea rows="5"/>
      </div>
      <div>
        <label>Buffered other labels</label>
        <textarea rows="5"/>
      </div>
    </div>
  </div>
</template>

<script>

  import CatalogNumber from './catalogNumber.vue'

  export default {
    components: {
      CatalogNumber
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