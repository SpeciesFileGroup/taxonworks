<!-- https://www.itsolutionstuff.com/post/file-upload-using-vue-js-axios-phpexample.html -->
<template>
  <div id="vue-task-dwca-import-new">
    <h1>DwC-A file upload</h1>
    <div
      v-if="table"
      class="position-relative">
      <table-component
        :table="table"/>
    </div>
    <new-import
      @onCreate="loadDataset($event.id)"
      v-else/>
  </div>
</template>

<script>

import NewImport from './components/NewImport'
import TableComponent from './components/table'
import { GetDataset, GetDatasetRecords } from './request/resources'
import GetPagination from 'helpers/getPagination'

export default {
  components: {
    NewImport,
    TableComponent
  },
  data () {
    return {
      importId: undefined,
      table: undefined,
      pagination: undefined
    }
  },
  mounted () {
    const ID = new URLSearchParams(window.location.search).get('import_dataset_id')
    if (ID) {
      this.importId = ID
      this.loadDataset(ID)
    }

    window.onscroll = () => {
      const bottomOfTable = document.documentElement.scrollTop + window.innerHeight === document.documentElement.offsetHeight

      if (bottomOfTable && this.importId) {
        if (this.pagination.nextPage) {
          this.loadDatasetRecords(this.importId, this.pagination.nextPage)
        }
      }
    }
  },
  methods: {
    loadDatasetRecords (id, page = undefined) {
      GetDatasetRecords(id, { page: page }).then(response => {
        this.pagination = GetPagination(response)
        this.table.rows = this.table.rows.concat(response.body)
      })
    },
    loadDataset (id) {
      let table = {}
      GetDataset(id).then(response => {
        table.headers = response.body.metadata.core_headers
        return GetDatasetRecords(id)
      }).then(response => {
        table.rows = response.body
        this.pagination = GetPagination(response)
        this.table = table
      })
    }
  }
}
</script>
