<template>
  <div id="vue-matrix-image">
    <spinner-component
      :full-screen="true"
      :legend="('Saving changes...')"
      :logo-size="{ width: '100px', height: '100px'}"
      v-if="isSaving"/>
    <row-modal
      v-if="showRowModal"
      @close="showRowModal = false"
      @create="addRow"
      :matrix-id="observationMatrix.id"/>
    <column-modal
      v-if="showColumnModal"
      @close="showColumnModal = false"
      @create="addColumn"
      :matrix-id="observationMatrix.id"
    />
    <div class="flex-separate">
      <h1>Image matrix</h1>
      <ul class="context-menu">
        <li v-if="!viewMode">
          <autocomplete
            url="/observation_matrices/autocomplete"
            param="term"
            label="label_html"
            clear-after
            placeholder="Select a matrix"
            @getItem="loadMatrix($event.id)"
          />
        </li>
        <template v-if="matrixId">
          <li>
            <label class="cursor-pointer middle">
              <input
                v-model="viewMode"
                type="checkbox">
              View mode
            </label>
          </li>
          <li>
            <span
              class="cursor-pointer"
              @click="showColumnModal = true">Add column</span>
          </li>
          <li>
            <span
              class="cursor-pointer"
              @click="collapseAll">Collapse all</span>
          </li>
          <li>
            <span 
              class="cursor-pointer"
              data-icon="reset"
              @click="resetTable">Reset</span>
          </li>
        </template>
        <li>
          <a :href="RouteNames.ObservationMatricesDashboard">Observation matrix dashboard</a>
        </li>
        <li>
          <a :href="RouteNames.ObservationMatricesHub">Observation matrix hub</a>
        </li>
      </ul>
    </div>
    <h3 v-if="observationMatrix">{{ observationMatrix.object_tag }}</h3>
    <template v-if="observationMatrix">
      <autocomplete
        url="/observation_matrix_rows/autocomplete"
        param="term"
        label="label"
        placeholder="Search a row"
        :clear-after="true"
        :add-params="{ observation_matrix_id: matrixId }"
        @getItem="findRow($event.id, $event.position)"
      />
    </template>
    <template v-if="matrixId && !viewMode">
      <matrix-table
        class="separate-table"
        ref="matrixTable"
        :columns="observationColumns"
        :rows="observationRows"/>
      <pagination-component
        :pagination="pagination"
        @nextPage="getRows($event.page)"/>
    </template>
    <view-component
      v-if="viewMode"
      class="separate-table"
      :matrix-id="matrixId"
      :otus-id="otuFilter"/>
  </div>
</template>

<script>
import {
  Otu,
  ObservationMatrix
} from 'routes/endpoints'

import MatrixTable from './components/MatrixTable.vue'
import SpinnerComponent from 'components/spinner.vue'
import RowModal from './components/RowModal.vue'
import ColumnModal from './components/ColumnModal.vue'
import ViewComponent from './components/View/Main.vue'
import Autocomplete from 'components/ui/Autocomplete.vue'
import PaginationComponent from 'components/pagination.vue'

import { GetterNames } from './store/getters/getters'
import { RouteNames } from 'routes/routes'

import GetPagination from 'helpers/getPagination.js'
import scrollParentToChild from 'helpers/scrollParentToChild.js'
import setParam from 'helpers/setParam'

export default {
  components: {
    ViewComponent,
    MatrixTable,
    SpinnerComponent,
    RowModal,
    ColumnModal,
    PaginationComponent,
    Autocomplete
  },

  computed: {
    isSaving () {
      return this.$store.getters[GetterNames.GetIsSaving]
    },
    RouteNames: () => RouteNames
  },

  data () {
    return {
      observationMatrix: undefined,
      observationColumns: [],
      observationRows: [],
      showRowModal: false,
      showColumnModal: false,
      matrixId: undefined,
      pagination: {},
      maxPerPage: 3,
      otu_ids: undefined,
      viewMode: false,
      otuFilter: []
    }
  },

  created () {
    const urlParams = new URLSearchParams(window.location.search)
    const obsIdParam = urlParams.get('observation_matrix_id')
    const rowIdParam = urlParams.get('row_id')
    const rowPositionParam = urlParams.get('row_position')
    const otuIdsParam = urlParams.get('otu_ids')
    const otuFilterParam = urlParams.get('otu_filter')

    if (otuFilterParam) {
      this.otuFilter = otuFilterParam
      this.viewMode = true
    }
    if (otuIdsParam) {
      this.otu_ids = otuIdsParam
    }
    if (/^\d+$/.test(obsIdParam)) {
      this.loadMatrix(obsIdParam, /^\d+$/.test(rowIdParam) ? rowIdParam : undefined, /^\d+$/.test(rowPositionParam) ? rowPositionParam : undefined)
    }
  },

  methods: {
    resetTable () {
      this.$refs.matrixTable.reset()
    },
    collapseAll () {
      this.$refs.matrixTable.collapseAll()
    },
    addRow (row) {
      this.showRowModal = false
      if (row.hasOwnProperty('otu_id')) {
        Otu.find(row.otu_id).then(response => {
          row.row_object = response.body
          this.observationRows.push(row)
        })
      }
    },

    addColumn (column) {
      this.showColumnModal = false
      this.observationColumns.push(column)
    },

    loadMatrix (id, rowId = undefined, position = undefined) {
      const promises = []

      this.matrixId = id
      setParam(RouteNames.ImageMatrix, 'observation_matrix_id', id)
      promises.push(ObservationMatrix.find(id).then(response => { this.observationMatrix = response.body }))
      promises.push(ObservationMatrix.columns(id).then(response => { this.observationColumns = response.body }))

      Promise.all(promises).then(() => { 
        if (rowId && position) {
          this.findRow(rowId, Number(position))
        } else {
          this.getRows(1)
        }
      })
    },

    getRows (page) {
      return new Promise((resolve, reject) => {
        ObservationMatrix.rows(this.matrixId, {
          page,
          per: this.maxPerPage,
          otu_ids: this.otu_ids
        }).then(response => {
          this.observationRows = response.body
          this.pagination = GetPagination(response)
          return resolve(response.body)
        })
      })
    },

    findRow (rowId, position) {
      if (this.observationRows.find(item => item.id === rowId)) {
        scrollParentToChild(document.querySelector('tbody'), document.querySelector(`[data-matrix-id="${rowId}"]`))
      } else {
        const page = Math.ceil((position) / this.maxPerPage)
        this.getRows(page).then(() => {
          this.$nextTick(() => {
            scrollParentToChild(document.querySelector('tbody'), document.querySelector(`[data-matrix-id="${rowId}"]`))
          })
        })
      }
    }
  }
}
</script>
<style scoped>
.separate-table {
  margin-top: 100px;
}
</style>
