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
      <transition name="bounce">
        <div
          v-if="isProcessing"
          class="show-import-process panel">
          <spinner-component
            legend="Importing rows... please wait."
          />
        </div>
      </transition>
      <navbar-component
        :pagination="pagination"
        :rows-count="table.rows.length"
        @select="selectAll"
        @unselect="unselectAll"
        @import="processImport"/>
      <table-component
        :import-id="importId"
        :table="table"
        :disabled="isProcessing"
        v-model="selectedIds"
        @onParams="tableParams = $event"/>
      <div style="height: 60px"/>
    </div>
    <new-import
      @onCreate="loadDataset($event.id)"
      v-else/>
  </div>
</template>

<script>

import NewImport from './components/NewImport'
import TableComponent from './components/table'
import NavbarComponent from './components/NavBar'
import { GetDataset, GetDatasetRecords, ImportRows } from './request/resources'
import GetPagination from 'helpers/getPagination'
import SpinnerComponent from 'components/spinner'
import Qs from 'qs'

export default {
  components: {
    NewImport,
    TableComponent,
    SpinnerComponent,
    NavbarComponent
  },
  data () {
    return {
      importId: undefined,
      table: undefined,
      pagination: undefined,
      isLoading: false,
      tableParams: undefined,
      isProcessing: false,
      selectedIds: []
    }
  },
  watch: {
    tableParams: {
      handler (newVal) {
        this.loadDatasetRecords(this.importId, undefined, newVal)
      },
      deep: true
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
    loadDatasetRecords (id, page = undefined, params = {}) {
      this.isLoading = true
      GetDatasetRecords(id, { params: Object.assign({}, { page: page }, params), paramsSerializer: (params) => Qs.stringify(params, { arrayFormat: 'brackets' }) }).then(response => {
        this.pagination = GetPagination(response)
        this.table.rows = page ? this.table.rows.concat(response.body) : response.body
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
          this.loadDatasetRecords(this.importId, this.pagination.nextPage, this.tableParams)
        }
      }
    },
    selectAll () {
      this.selectedIds = this.table.rows.filter(row => row.status === 'Ready').map(row => row.id)
    },
    unselectAll () {
      this.selectedIds = []
    },
    processImport () {
      this.isProcessing = true
      ImportRows(this.importId).then(response => {
        if (response.body.results.length) {
          this.processImport()
        } else {
          this.loadDatasetRecords(this.importId)
          this.isProcessing = false
        }
      }, () => {
        this.isProcessing = false
      })
    }
  }
}
</script>
<style scoped>
  .show-import-process {
    width: 400px;
    position: fixed;
    bottom: 0px;
    height: 100px;
    z-index: 201;
    left: calc(50% - 200px);
  }
</style>
