<!-- https://www.itsolutionstuff.com/post/file-upload-using-vue-js-axios-phpexample.html -->
<template>
  <div id="vue-task-dwca-import-new">
    <h1>DwC-A file upload</h1>
    <div
      v-if="table"
      class="overflow-scroll">
      <table-component
        :table="table"/>
    </div>
    <new-import v-else/>
  </div>
</template>
  
<script>

import NewImport from './components/NewImport'
import TableComponent from './components/table'
import { GetDataset, GetDatasetRecords } from './request/resources'

  export default {
    components: {
      NewImport,
      TableComponent
    },
    data (){
      return {
        table: undefined
      }
    },
    mounted () {
      let id = new URLSearchParams(window.location.search).get('import_dataset_id')
      let table = {}

      GetDataset(id).then(response => {
        table.headers = response.body.metadata.core_headers
        return GetDatasetRecords(id)
      }).then(response => {
        table.rows = response.body
        this.table = table
      })
    }
  }
</script>