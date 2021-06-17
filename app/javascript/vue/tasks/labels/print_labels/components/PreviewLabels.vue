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

    customStyle: {
      type: String,
      default: ''
    },

    rows: {
      type: [String, Number],
      required: true
    },

    columns: {
      type: [String, Number],
      required: true
    },

    labels: {
      type: Array,
      default: () => ([])
    },

    divisor: {
      type: Boolean,
      default: false
    },

    separator: {
      type: String,
      default: ''
    }

  },
  methods: {
    renderLabels() {
      const w = window.open()

      w.document.write(createLabels(this.labels, this.columns, this.rows, this.divisor, this.classSelected, this.customStyle, this.separator, this.divisor))
      w.document.close()
    }
  }
}
</script>
