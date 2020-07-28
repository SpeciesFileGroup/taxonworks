<template>
  <div id="vue-task-dwca-import-new">
    <spinner-component
      :full-screen="true"
      legend="Loading records..."
      v-if="isLoading"/>
    <h1>DwC-A Workbench</h1>
    <template v-if="table">
      <div class="position-relative">
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
          @onUpdateRow="updateRow"
          @onParams="tableParams = $event"/>
        <div style="height: 60px"/>
      </div>
    </template>
    <template v-else>
      <new-import @onCreate="loadDataset($event.id)"/>
      <import-list @onSelect="loadDataset"/>
    </template>
  </div>
</template>

<script>

import NewImport from './components/NewImport'
import ImportList from './components/ImportList'
import TableComponent from './components/table'
import NavbarComponent from './components/NavBar'
import { GetDataset, GetDatasetRecords, ImportRows } from './request/resources'
import { RouteNames } from 'routes/routes'
import SetParam from 'helpers/setParam.js'
import GetPagination from 'helpers/getPagination'
import SpinnerComponent from 'components/spinner'
import Qs from 'qs'

export default {
  components: {
    NewImport,
    ImportList,
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
        SetParam(RouteNames.DwcImport, 'import_dataset_id', id)
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
        if (this.pagination.nextPage && this.pagination.nextPage > this.pagination.paginationPage) {
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
          response.body.results.forEach(row => {
            this.updateRow(row)
          })
          this.processImport()
        } else {
          this.isProcessing = false
        }
      }, () => {
        this.isProcessing = false
      })
    },
    updateRow (row) {
      const index = this.table.rows.findIndex(item => item.id === row.id)
      if (index > -1) {
        this.$set(this.table.rows, index, row)
      }
    }
  }
}
</script>
<style lang="scss">
  #vue-task-dwca-import-new {
    .show-import-process {
      width: 400px;
      position: fixed;
      bottom: 0px;
      height: 100px;
      z-index: 201;
      left: calc(50% - 200px);
    }

    .column-filter {
      .filter-container {
        display: none;
        min-width: 200px;
        left:0;
        position: absolute;
      }
      .vue-autocomplete-input {
        width: 200px;
      }
    }
    .column-filter:hover {
      .filter-container {
        display: flex;
      }
    }
  }
</style>
