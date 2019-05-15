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
      default: () => { return [] }
    },
    options: {
      type: [Array, Object],
      default: () => { return [] }
    }
  },
  data() {
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
    parseJSONToCSV() {
      try {
        this.csvFile = parse(this.list, this.options)
      } catch (err) {
        console.error(err)
      }
    },
    downloadCSV() {
      window.open(encodeURI(`data:text/csv;charset=utf-8,${this.csvFile}`));
    }
  }
}
</script>