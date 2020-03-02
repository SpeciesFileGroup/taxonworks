<template>
  <div>
    <spinner-component
      v-if="isLoading"
      :full-screen="true"/>
    <button
      class="button normal-input button-default"
      @click="getRecords">
      Download CSV
    </button>
  </div>
</template>

<script>

import { parse } from 'json2csv'
import AjaxCall from 'helpers/ajaxCall'
import SpinnerComponent from 'components/spinner'
 
export default {
  components: {
    SpinnerComponent
  },
  props: {
    options: {
      type: [Array, Object],
      default: () => { return [] }
    },
    url: {
      type: String,
      default: undefined
    }
  },
  data() {
    return {
      csvFile: undefined,
      isLoading: false,
      list: []
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
    getRecords () {
      let params = new URLSearchParams(this.url.split('?')[1])
      params.delete('per')
      AjaxCall('get', `${this.url.split('?')[0]}?${params}`).then(response => {
        this.list = response.body.data
        this.isLoading = false
        this.parseJSONToCSV()
        this.downloadCSV()
      }, () => {
        this.isLoading = false
      })
    },
    downloadCSV() {
      var a = window.document.createElement('a');
      a.href = window.URL.createObjectURL(new Blob([this.csvFile], { type: 'text/csv' }))
      a.download = 'list.csv'

      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
    }
  }
}
</script>