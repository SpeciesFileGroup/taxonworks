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
        <li>
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
          <a href="/tasks/observation_matrices/observation_matrix_hub/index">Back to observation matrix hub</a>
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
    <template v-if="matrixId">
      <view-component
        v-if="viewMode"
        class="separate-table"
        :matrix-id="matrixId"/>
      <template v-else>
        <matrix-table
          class="separate-table"
          ref="matrixTable"
          :columns="observationColumns"
          :rows="observationRows"/>
        <pagination-component
          :pagination="pagination"
          @nextPage="getRows($event.page)"/>
      </template>
    </template>
  </div>
</template>

<script>

import {
  GetObservationMatrix,
  GetMatrixObservationColumns,
  GetMatrixObservationRows,
  GetOtu } from './request/resources'

import MatrixTable from './components/MatrixTable.vue'
import SpinnerComponent from 'components/spinner.vue'
import RowModal from './components/RowModal.vue'
import ColumnModal from './components/ColumnModal.vue'
import ViewComponent from './components/View/Main.vue'
import Autocomplete from 'components/autocomplete.vue'
import PaginationComponent from 'components/pagination.vue'

import { GetterNames } from './store/getters/getters'
import GetPagination from 'helpers/getPagination.js'
import { RouteNames } from 'routes/routes'

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
    isSaving() {
      return this.$store.getters[GetterNames.GetIsSaving]
    }
  },
  data() {
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
      viewMode: false
    }
  },
  created() {
    const urlParams = new URLSearchParams(window.location.search)
    const obsIdParam = urlParams.get('observation_matrix_id')
    const rowIdParam = urlParams.get('row_id')
    const rowPositionParam = urlParams.get('row_position')
    const otuIdsParam = urlParams.get('otu_ids')
    if (otuIdsParam) {
      this.otu_ids = otuIdsParam
    }
    if (/^\d+$/.test(obsIdParam)) {
      this.loadMatrix(obsIdParam, /^\d+$/.test(rowIdParam) ? rowIdParam : undefined, /^\d+$/.test(rowPositionParam) ? rowPositionParam : undefined)
    }
  },
  methods: {
    resetTable() {
      this.$refs.matrixTable.reset()
    },
    collapseAll() {
      this.$refs.matrixTable.collapseAll()
    },
    addRow(row) {
      this.showRowModal = false
      if(row.hasOwnProperty('otu_id')) {
        GetOtu(row.otu_id).then(response => {
          row.row_object = response.body
          this.observationRows.push(row)
        })
      }
    },
    addColumn(column) {
      this.showColumnModal = false
      this.observationColumns.push(column)
    },
    loadMatrix(id, rowId = undefined, position = undefined) {
      this.matrixId = id
      let promises = []
      setParam(RouteNames.ImageMatrix, 'observation_matrix_id', id)
      promises.push(GetObservationMatrix(id).then(response => {
        this.observationMatrix = response.body
      }))
      promises.push(GetMatrixObservationColumns(id).then(response => {
        this.observationColumns = response.body
      }))

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
        GetMatrixObservationRows(this.matrixId, { params: { per: this.maxPerPage, page: page, otu_ids: this.otu_ids } }).then(response => {
          this.observationRows = response.body
          this.pagination = GetPagination(response)
          return resolve(response.body)
        })
      })
    },
    findRow (rowId, position) {
      if (this.observationRows.find(item => {
        return item.id === rowId
      })) {
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
