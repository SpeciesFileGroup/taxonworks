<template>
  <div>
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
            placeholder="Select a matrix"
            @getItem="loadMatrix($event.id)"
          />
        </li>
        <template v-if="matrixId">
          <li>
            <span
              class="cursor-pointer"
              @click="showRowModal = true">Add row</span>
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
    <matrix-table
      v-if="matrixId"
      class="separate-table"
      ref="matrixTable"
      :columns="observationColumns"
      :rows="observationRows"/>
  </div>
</template>

<script>

import {
    GetObservationMatrix,
    GetMatrixObservationColumns,
    GetMatrixObservationRows,
    GetOtu,
    GetCollectionObject } from './request/resources'

import MatrixTable from './components/MatrixTable.vue'
import SpinnerComponent from 'components/spinner.vue'
import RowModal from './components/RowModal.vue'
import ColumnModal from './components/ColumnModal.vue'
import Autocomplete from 'components/autocomplete.vue'

import { GetterNames } from './store/getters/getters'

export default {
  components: {
    MatrixTable,
    SpinnerComponent,
    RowModal,
    ColumnModal,
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
      matrixId: undefined
    }
  },
  created() {
    let urlParams = new URLSearchParams(window.location.search)
    let obsIdParam = urlParams.get('observation_matrix_id')
    if (/^\d+$/.test(obsIdParam)) {
      this.loadMatrix(obsIdParam)
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
    loadMatrix(id) {
      this.matrixId = id
      GetObservationMatrix(id).then(response => {
        this.observationMatrix = response.body
      })
      GetMatrixObservationColumns(id).then(response => {
        this.observationColumns = response.body
      })
      GetMatrixObservationRows(id).then(response => {
        this.observationRows = response.body
      })
    }
  }
}
</script>
<style scoped>
.separate-table {
  margin-top: 100px;
}
</style>
