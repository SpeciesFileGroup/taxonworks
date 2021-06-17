<template>
  <button
    :disabled="!csvFile"
    class="button normal-input button-default"
    @click="downloadCSV">
    Download CSV
  </button>
</template>

<script>

import { parse } from 'json2csv'
 
export default {
  props: {
    list: {
      type: Array,
      default: () => []
    },

    options: {
      type: [Array, Object],
      default: () => []
    },

    filename: {
      type: String,
      default: 'list.csv'
    }
  },

  data () {
    return {
      csvFile: undefined,
    }
  },

  watch: {
    list: {
      handler(newVal) {
        if(newVal.length)
          this.parseJSONToCSV()
        else 
          this.csvFile = undefined
      },
      deep: true,
      immediate: true
    },

    options: {
      handler(newVal) {
        if(this.list.length)
          this.parseJSONToCSV()
        else 
          this.csvFile = undefined
      },
      deep: true,
      immediate: true 
    }
  },

  methods: {
    parseJSONToCSV () {
      try {
        this.csvFile = parse(this.list, this.options)
      } catch (err) {
        console.error(err)
      }
    },

    downloadCSV() {
      const a = window.document.createElement('a')
      a.href = window.URL.createObjectURL(new Blob([this.csvFile], { type: 'text/csv' }))
      a.download = this.filename

      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
    }
  }
}
</script>
