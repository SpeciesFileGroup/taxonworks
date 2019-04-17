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
 
const fields = ['name_string', 'original_combination', 'year_of_publication', 'rank'];
const opts = { fields };
 
export default {
  props: {
    list: {
      type: Array,
      default: () => { return [] }
    }
  },
  data() {
    return {
      csvFile: undefined,
    }
  },
  watch: {
    list() {
      this.parseJSONToCSV()
    }
  },
  methods: {
    parseJSONToCSV() {
      try {
        this.csvFile = parse(this.list, opts);
      } catch (err) {
        console.error(err);
      }
    },
    downloadCSV() {
      window.open(encodeURI(`data:text/csv;charset=utf-8,${this.csvFile}`));
    }
  }
}
</script>
