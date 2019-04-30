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
 
const fields = [
  'id',
  { label: 'name', value: 'cached' }, 
  { label: 'author', value: 'verbatim_author' },
  { label: 'year of publication', value: 'year_of_publication' },
  { label: 'original combination', value: 'cached_original_combination' }, 
  'rank',
  { label: 'parent', value: 'parent.cached' }];
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
    list(newVal) {
      if(newVal.length)
        this.parseJSONToCSV()
      else {
        this.csvFile = undefined
      }
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
