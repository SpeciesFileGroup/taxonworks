<template>
  <button 
    type="button"
    class="button normal-input button-default"
    @click="renderLabels">
    Preview/Print
  </button>
</template>

<script>

import createLabels from '../helpers/createLabels.js'

export default {
  props: {
    classSelected: {
      type: String,
      default: 'ce'
    },
    rows: {
      type: [String, Number],
      default: 3
    },
    cols: {
      type: [String, Number],
      default: 2
    },
    labels: {
      type: Array,
      default: () => { return [] }
    },
    divisor: {
      type: Boolean,
      default: false
    }

  },
  methods: {
    renderLabels() {
      var w = window.open()

      w.document.write(createLabels(this.labels, this.cols, this.rows, this.divisor, this.classSelected))
        //w.print();      
    }
  }
}
</script>

<style lang="scss">
  @import '../stylesheets/ce.css';
</style>
