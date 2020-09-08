<template>
  <div id="vue-task-dwca-import-new">
    <spinner-component
      :full-screen="true"
      legend="Loading records..."
      v-if="isLoading"/>
    <h1>DwC-A Workbench</h1>
    <template v-if="dataset.id">
      <div class="position-relative">
        <navbar-component/>
        <table-component
          :disabled="isProcessing"/>
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
import { ImportRows } from './request/resources'
import { GetterNames } from './store/getters/getters'
import { MutationNames } from './store/mutations/mutations'
import { ActionNames } from './store/actions/actions'

import SpinnerComponent from 'components/spinner'

export default {
  components: {
    NewImport,
    ImportList,
    TableComponent,
    SpinnerComponent,
    NavbarComponent
  },
  computed: {
    datasetRecords: {
      get () {
        return this.$store.getters[GetterNames.GetDatasetRecords]
      },
      set (value) {
        this.$store.commit(MutationNames.SetDatasetRecords, value)
      }
    },
    dataset () {
      return this.$store.getters[GetterNames.GetDataset]
    },
    pagination: {
      get () {
        return this.$store.getters[GetterNames.GetPagination]
      },
      set (value) {
        this.$store.commit(MutationNames.SetPagination, value)
      }
    }
  },
  data () {
    return {
      isLoading: false,
      isProcessing: false
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
    loadDataset (id) {
      this.$store.dispatch(ActionNames.LoadDataset, id).then(() => {
        this.$store.dispatch(ActionNames.LoadDatasetRecords)
      })
    },
    checkScroll () {
      const bottomOfTable = (document.documentElement.scrollTop + window.innerHeight) >= document.documentElement.offsetHeight

      if (bottomOfTable && this.dataset.id) {
        if (this.pagination.nextPage && this.pagination.nextPage > this.pagination.paginationPage) {
          this.$store.dispatch(ActionNames.LoadDatasetRecords, this.pagination.nextPage)
        }
      }
    },
    unselectAll () {
      this.selectedIds = []
    },
    processImport () {
      this.isProcessing = true
      ImportRows(this.dataset.id).then(response => {
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
    }
  }
}
</script>
<style lang="scss">
  #vue-task-dwca-import-new {
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
