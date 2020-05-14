<!-- https://www.itsolutionstuff.com/post/file-upload-using-vue-js-axios-phpexample.html -->
<template>
  <div id="vue-task-dwca-import-new">
    <spinner-component
      :full-screen="true"
      legend="Loading records..."
      v-if="isLoading"/>
    <h1>DwC-A Workbench</h1>
    <div
      v-if="table"
      class="position-relative">
      <table-component
        :import-id="importId"
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
import SpinnerComponent from 'components/spinner'

export default {
  components: {
    NewImport,
    TableComponent,
    SpinnerComponent
  },
  data () {
    return {
      importId: undefined,
      table: undefined,
      pagination: undefined,
      isLoading: false
    }
  },
  mounted () {
    const ID = new URLSearchParams(window.location.search).get('import_dataset_id')
    if (ID) {
      this.loadDataset(ID)
    }
    document.addEventListener('turbolinks:load', () => { window.removeEventListener('scroll', this.checkScroll) })
    window.addEventListener('scroll', this.checkScroll)
  },
  methods: {
    loadDatasetRecords (id, page = undefined) {
      this.isLoading = true
      GetDatasetRecords(id, { page: page }).then(response => {
        this.pagination = GetPagination(response)
        this.table.rows = this.table.rows.concat(response.body)
        this.isLoading = false
      })
    },
    loadDataset (id) {
      let table = {}
      this.importId = id
      this.isLoading = true
      GetDataset(id).then(response => {
        table.headers = response.body.metadata.core_headers
        return GetDatasetRecords(id)
      }).then(response => {
        table.rows = response.body
        this.pagination = GetPagination(response)
        this.table = table
        this.isLoading = false
      })
    },
    checkScroll () {
      const bottomOfTable = (document.documentElement.scrollTop + window.innerHeight) >= document.documentElement.offsetHeight

      if (bottomOfTable && this.importId) {
        if (this.pagination.nextPage) {
          this.loadDatasetRecords(this.importId, this.pagination.nextPage)
        }
      }
    }
  }
}
</script>
